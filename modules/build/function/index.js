const AWS = require('aws-sdk');
const s3 = new AWS.S3({signatureVersion: 'v4'});
const cloudfront = new AWS.CloudFront();
const async = require('async');
const mime = require('mime');
const path = require('path');
const yaml = require('js-yaml');
const {link} = require('linkfs');
const mock = require('mock-require');
const fs = require('fs');

const stripAnsi = require('strip-ansi');

const linkedFs = link(fs, [
    [`${__dirname}/.cache`, require('os').tmpdir() + '/.cache'],
    [`${__dirname}/public`, require('os').tmpdir() + '/public'],
    [`${__dirname}/src/posts`, require('os').tmpdir() + '/posts']
]);
linkedFs.ReadStream = fs.ReadStream;
linkedFs.WriteStream = fs.WriteStream;

mock('fs', linkedFs);

const readdirp = require('readdirp');
const fsExtra = require('fs-extra');

const log = console.log;
console.log = (args) => {
    log(stripAnsi(args))
};

const cleanDirs = () => {
    fsExtra.ensureDirSync(require('os').tmpdir() + '/posts');
    fsExtra.ensureDirSync(require('os').tmpdir() + '/.cache');
    fsExtra.ensureDirSync(require('os').tmpdir() + '/public');

    fsExtra.emptyDirSync(require('os').tmpdir() + '/public');
    fsExtra.emptyDirSync(require('os').tmpdir() + '/posts');
    fsExtra.emptyDirSync(require('os').tmpdir() + '/.cache');
};

exports.handler = function (event, context) {
    cleanDirs();

    console.log('event ', JSON.stringify(event));

    getContents(null, (err, objects) => {
        // Handle error
        if (err) {
            context.fail(err, err.stack);
            return;
        }

        createPosts(objects, () => {
            // Invalidate CloudFront
            uploadToSiteBucket(context.fail, () => {
                //TODO remove temp files
                invalidateCloudFront(context.succeed)
            });
        }, context.fail);
    });
};

const clearSiteBucket = (errorCallback, callback) => {
    s3.listObjectsV2({Bucket: process.env.SITE_BUCKET}, (err, objects) => {
        if (err) {
            errorCallback(err, err.stack);
        }
        async.map(objects.Contents, (file, cb) => s3.deleteObject({
            Bucket: process.env.SITE_BUCKET,
            Key: file.Key
        }, cb), callback);
    })
};

const uploadToSiteBucket = (errorCallback, callback) => {
    const folder = require('os').tmpdir() + '/public';

    clearSiteBucket(errorCallback, () => {
        readdirp({root: folder}, () => {
        }, (err, entries) => {
            if (err) {
                errorCallback(err, err.stack);
            }
            console.log('uploading files', JSON.stringify(entries.files.map((file) => file.path)));
            async.map(entries.files, (file, cb) => {
                writeFile(file.path, fs.readFileSync(file.fullPath, 'utf-8'), (err) => {
                    if (err) {
                        errorCallback(err, err.stack);
                    }
                    cb();
                });
            }, callback);
        })
    });
};

const createStaticSite = (callback, errorCallback) => {
    process.env.NODE_ENV = 'production';
    const gatsby = require('gatsby/dist/commands/build');

    gatsby({
        directory: __dirname,
    }).then(callback).catch(errorCallback);
};

const createPosts = (objects, callback, errorCallback) => {
    // Parse albums
    const albums = getAlbums(objects);

    async.map(albums, writeAlbum, (err) => {
        if (err) {
            return errorCallback(err, err.stack);
        }

        createStaticSite(callback, errorCallback);
    });
};

const writeAlbum = (album, cb) => {
    getAlbumMetadata(album.name, (err, post) => {
        writePost({
            title: album.name,
            images: album.images,
            path: path.join('/', album.name.toLowerCase(), '/'),
            date: album.date.toISOString(),
            post
        });
        cb();
    });
};

const writePost = (config) => {
    const publicImages = config.images
        .filter((image) => image.Key.indexOf('.png') === -1)
        .map((image) => {
            const key = encodeURI(image.Key.replace('original/', ''));

            if ([".mov", ".mp4"].includes(path.extname(key).toLowerCase())) {
                return {src: `/original/${key.replace(path.extname(key), ".mp4")}`}
            }

            return {
                src: `/pics/resized/1200x750/${key}`,
                srcSet: [
                    `/pics/resized/1200x750/${key} 800w`,
                    `/pics/resized/560x425/${key} 500w`
                ]
            }
        });

    const content = `---
${yaml.safeDump({title: config.title, images: publicImages, date: config.date, path: config.path + 'index.html'})}
---

${config.post || ''}
    `;

    console.log(`generating post "${config.title}"`, content);

    try {
        fs.mkdirSync(`${require('os').tmpdir()}/posts${config.path}`);
    } catch (e) {
    }
    fs.writeFileSync(`${require('os').tmpdir()}/posts${config.path}index.md`, content);
};

let objects = [];

const getContents = (NextToken, callback) => {
    s3.listObjectsV2({
        Bucket: process.env.ORIGINAL_BUCKET,
        Prefix: 'original/',
        ContinuationToken: NextToken
    }, (err, data) =>{
        objects = objects.concat(data.Contents);
        if (data.NextContinuationToken) {
            getContents(data.NextContinuationToken, callback);
        } else {
            data.Contents = objects;
            callback(err, data);
        }
    });
};

const getAlbums = (data) => {
    const objects = data.Contents.sort((a, b) => {
        return b.LastModified - a.LastModified;
    });

    return objects.map(folderName)
        .filter((item, pos, folders) => folders.indexOf(item) === pos)
        .filter((album) => album)
        .map((album) => {
            return {
                name: album,
                images: objects.filter((object) => object.Key.startsWith(`original/${album}/`) && isAlbumFile(object)),
                date: objects.filter((object) => object.Key.startsWith(`original/${album}/`)).shift().LastModified
            }
        });
};

const getAlbumMetadata = (album, cb) => {
    s3.getObject({
        'Bucket': process.env.ORIGINAL_BUCKET,
        'Key': `original/${album}/post.md`
    }, (err, data) => {
        if (err) {
            cb(null, null);
        } else {
            let content = null;
            try {
                content = data.Body.toString();
            } catch (err) {
            }
            cb(null, content);
        }
    });
};

const writeFile = (key, body, callback) => {
    s3.putObject({
        Bucket: process.env.SITE_BUCKET,
        Key: key,
        Body: body,
        ContentType: mime.lookup(path.extname(key))
    }, callback);
};

const isAlbumFile = (object) => ['.jpg', '.jpeg', '.png','.mp4','.mov'].indexOf(path.extname(object.Key).toLowerCase()) !== -1;
const folderName = (file) => file.Key.split('/')[1];

const invalidateCloudFront = (callback) => {
    cloudfront.listDistributions((err, data) => {
        // Handle error
        if (err) {
            console.log(err, err.stack);
            return;
        }

        // Get distribution ID from domain name
        const distribution = data.Items.find(d => d.Aliases.Items.includes(process.env.WEBSITE));
        if (!distribution) {
            console.log(`cloudfront distribution for domain "${process.env.WEBSITE}" not found`);

            return callback();
        }

        // Create invalidation
        cloudfront.createInvalidation({
            DistributionId: distribution.Id,
            InvalidationBatch: {
                CallerReference: 'site-builder-' + Date.now(),
                Paths: {
                    Quantity: 1,
                    Items: ['/*']
                }
            }
        }, (err) => {
            if (err) console.log(err, err.stack);

            callback();
        });
    });
};
