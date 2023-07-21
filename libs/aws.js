import { Upload } from "@aws-sdk/lib-storage";
import { S3Client, DeleteObjectCommand } from "@aws-sdk/client-s3";

const s3 = new S3Client(); // automatically detects required credentails from the .env file

// NOTE: private key should be encoded base64 string using
// `- run command in shell `base64 private_key_here``

async function resolveSignedUrl(Key) {
  // const bufferObj = Buffer.from(process.env.CLOUDFRONT_PRIVATE_KEY, "base64");
  // const cloudfrontPrivateKey = bufferObj.toString("utf8");
  // const url = await getSignedUrl({
  //   url: `${process.env.CLOUDFRONT_DOMAIN}/${Key.split(" ").join("+")}`,
  //   dateLessThan: new Date(Date.now() + 1000 * 60 * 60 * 24), // 1 day
  //   privateKey: cloudfrontPrivateKey,
  //   keyPairId: process.env.CLOUDFRONT_KEY_PAIR_ID,
  // });
  const url = `${process.env.CLOUDFRONT_DOMAIN}/${Key.split(" ").join("+")}`;
  return url;
}

async function resolveUpload(upload, args, _context, _info) {
  if (!args.input.file) {
    return null;
  }
  const {
    input: { file },
  } = args;

  const { creatorId: userId, info } = file;

  const { filename, mimetype, createReadStream } = upload;
  const timestamp = new Date().toISOString().replace(/\D/g, "");
  const fileStream = await createReadStream();
  const updatedFileName = filename.split(" ").join("_");
  let filePath = `${userId}/${timestamp}_${updatedFileName}`;
  if (info && info.directory && info.directory.length > 0) {
    filePath = `${userId}/${info.directory}/${timestamp}_${updatedFileName}`;
  }
  try {
    const parallelUploads3 = new Upload({
      client: s3,
      params: {
        Bucket: process.env.S3_BUCKET_NAME,
        Key: filePath,
        Body: fileStream,
        ContentType: mimetype,
      },
    });
    // parallelUploads3.on("httpUploadProgress", (progress) => {
    //   console.log(progress);
    // });
    const data = await parallelUploads3.done();
    return data.Key;
  } catch (err) {
    console.log("Error", err);
  }
}

async function deleteS3File(fileInfo) {
  const command = new DeleteObjectCommand({
    Bucket: process.env.S3_BUCKET_NAME,
    Key: fileInfo.key,
  });
  try {
    await s3.send(command);
  } catch (err) {
    console.log("Error deleting s3 file: ", err);
  }
}

export { resolveUpload, resolveSignedUrl, deleteS3File, s3 };
