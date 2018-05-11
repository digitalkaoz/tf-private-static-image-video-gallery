const path = require("path");
const async = require("async");
const AWS = require("aws-sdk");
const im = require("gm").subClass({imageMagick: true});
const s3 = new AWS.S3({signatureVersion: 'v4'});
const Imagemin = require('imagemin');

const VARIANTS = ["1200x750", "560x425"];

exports.handler = (event, context) => {
    console.log("event ", JSON.stringify(event));

    async.mapLimit(event.Records, 4, processRecord, (err, files) => {
        if (err) {
            return context.fail(err);
        }

        //resize and copy images
        handleImages(context, files.filter((file) => file.imageType !== "binary"))
    });
};

const processRecord = (record, callback) => {
    const originalKey = decodeURIComponent(record.s3.object.key.replace(/\+/g, " "));

    switch (record.eventName) {
        case "ObjectCreated:Put":
        case "ObjectCreated:Copy":
            return getFile(record, originalKey, callback);
        case "ObjectRemoved:Delete":
            return callback(null, {
                "originalKey": originalKey,
                "record": record
            });
    }
};

const handleImages = (context, images) => {
    const variantPairs = cross(VARIANTS, images);

    async.eachLimit(variantPairs, 4, (variantPair, callback) => {
        const variant = variantPair[0];
        const image = variantPair[1];

        if (image.record.eventName === "ObjectRemoved:Delete") {
            removeFile(`pics/resized/${variant}/${image.originalKey}`, callback);
        } else {
            resize(variant, image, callback);
        }
    }, err => finalize(err, context));
};

const removeFile = (key, callback) => {
    key = key.replace("/original/", "/");

    console.log(`deleting file "${key}" in bucket "${process.env.RESIZED_BUCKET}"`);

    s3.deleteObject({
        Bucket: process.env.RESIZED_BUCKET,
        Key: key,
    }, err => callback(err));
};

const writeFile = (key, buffer, image, callback) => {
    key = key.replace("/original/", "/");

    console.log(`writing file "${key}" to bucket "${process.env.RESIZED_BUCKET}"`);

    s3.putObject({
        Bucket: process.env.RESIZED_BUCKET,
        Key: key,
        Body: buffer,
        ContentType: image ? image.contentType : "text/plain",
        // ServerSideEncryption: 'aws:kms',
        // SSEKMSKeyId: process.env.KMS_KEY_NAME,
    }, err => callback(err));
};

const getFile = (record, key, callback) => {
    s3.getObject({
        Bucket: record.s3.bucket.name,
        Key: key
    }, (err, data) => {
        if (err) {
            return callback(err);
        }

        console.log(`fetched "${key}"`);

        callback(null, {
            "originalKey": key,
            "contentType": data.ContentType,
            "imageType": getFileType(data.ContentType),
            "buffer": data.Body,
            "record": record
        });
    });
};

const getFileType = (objectContentType) => {
    switch (objectContentType) {
        case "image/jpeg":
            return "jpeg";
        case "image/png":
            return "png";
        case "binary/octet-stream":
            return "binary";
        default:
            throw new Error("unsupported objectContentType " + objectContentType);
    }
};

const cross = (variants, images) => {
    let res = [];

    variants.forEach(variant => images.forEach(image => res.push([variant, image])));

    return res;
};

const resize = (variant, image, callback) => {
    const width = variant.split('x')[0];
    const height = variant.split('x')[1];


    let operation = im(image.buffer, path.basename(image.originalKey))
        .autoOrient()
        .resize(width, height, '^');

    if (variant === "560x425") {
        operation = operation
            .gravity('Center')
            .crop(width, height);
    }

    console.log(`resizing "${image.originalKey}" as "${variant}"`);

    operation.toBuffer(image.imageType, (err, buffer) => {
        if (err) {
            return callback(err);
        }

        //the 5.x branch of imagemin doesnt work in lambda due to permissions
        new Imagemin()
            .src(buffer)
            .use(Imagemin.jpegtran({progressive: true}))
            .use(Imagemin.optipng({optimizationLevel: 3}))
            .run((err, files) => {
                if (err) {
                    return callback(err);
                }
                writeFile(`pics/resized/${variant}/${image.originalKey}`, files[0].contents, image, callback);
            });
    });
};

const finalize = (error, context) => {
    if (error) {

        return context.fail(error);
    }
    return context.succeed();
};
