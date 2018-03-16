const async = require("async");
const path = require("path");
const AWS = require("aws-sdk");
const s3 = new AWS.S3({signatureVersion: 'v4'});
const transcoder = new AWS.ElasticTranscoder({
    "region": process.env.REGION
});

exports.handler = (event, context) => {
    console.log("event ", JSON.stringify(event));

    async.mapLimit(event.Records, 4, processRecord, (err, data) => {
        if (err) {
            return context.fail(err);
        }

        context.succeed(data);
    });
};

const processRecord = (record, callback) => {
    const originalKey = decodeURIComponent(record.s3.object.key.replace(/\+/g, " "));

    switch (record.eventName) {
        case "ObjectCreated:Put":
        case "ObjectCreated:Copy":
        case "ObjectCreated:CompleteMultipartUpload":
            return createTranscoderJob(originalKey, callback);
        case "ObjectRemoved:Delete":
            return deleteTarget(originalKey, callback);
    }
};

const deleteTarget = (originalKey, callback) => {
    console.log(`deleting file "${originalKey}" in bucket "${process.env.RESIZED_BUCKET}"`);

    s3.deleteObject({
        Bucket: process.env.RESIZED_BUCKET,
        Key: originalKey,
    }, err => callback(err));
};

const createTranscoderJob = (originalKey, callback) => {
    console.log(`creating transcoder job for "${originalKey}"`);

    transcoder.createJob({
        PipelineId: process.env.PIPELINE_ID,
        Input: {
            Key: originalKey,
            FrameRate: "auto",
            Resolution: "auto",
            AspectRatio: "auto",
            Interlaced: "auto",
            Container: "auto",
        },
        Output: {
            Key: originalKey.replace(path.extname(originalKey), ".mp4"),
            Rotate: "auto",
            PresetId: process.env.PRESET_ID,
            ThumbnailPattern: originalKey.replace(path.extname(originalKey), "_{count}")
        }
    }, (err, data) => {
        console.log(JSON.stringify(data));
        callback(err, data);
    })
};
