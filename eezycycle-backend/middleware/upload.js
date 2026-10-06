const path = require('path');
const fs = require('fs');
const multer = require('multer');
const { createError, ErrorCodes } = require('../utils/error');

const postsDir = path.join(__dirname, '..', 'uploads', 'posts');
const avatarsDir = path.join(__dirname, '..', 'uploads', 'avatars');
fs.mkdirSync(postsDir, { recursive: true });
fs.mkdirSync(avatarsDir, { recursive: true });

function makeStorage(dir, prefix) {
  return multer.diskStorage({
    destination: (_req, _file, cb) => cb(null, dir),
    filename: (_req, file, cb) => {
      const ext = path.extname(file.originalname || '').toLowerCase() || '.jpg';
      const safeExt = ['.jpg', '.jpeg', '.png', '.webp'].includes(ext)
        ? ext
        : '.jpg';
      const name = `${prefix}_${Date.now()}_${Math.random()
        .toString(36)
        .slice(2, 10)}${safeExt}`;
      cb(null, name);
    },
  });
}

function fileFilter(_req, file, cb) {
  const ok = /^image\/(jpeg|jpg|png|webp)$/i.test(file.mimetype || '');
  if (!ok) {
    return cb(
      createError('Only JPEG, PNG, or WebP images are allowed.', 400, ErrorCodes.VALIDATION),
    );
  }
  cb(null, true);
}

function wrapMulter(upload) {
  return (req, res, next) => {
    upload(req, res, (err) => {
      if (!err) return next();
      if (err instanceof multer.MulterError) {
        if (err.code === 'LIMIT_FILE_SIZE') {
          return next(
            createError('Image is too large (max 5 MB).', 400, ErrorCodes.VALIDATION),
          );
        }
        return next(createError(err.message, 400, ErrorCodes.VALIDATION));
      }
      return next(err);
    });
  };
}

const uploadPostImage = multer({
  storage: makeStorage(postsDir, 'post'),
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 },
}).single('image');

const uploadAvatarImage = multer({
  storage: makeStorage(avatarsDir, 'avatar'),
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 },
}).single('avatar');

const optionalPostImage = wrapMulter(uploadPostImage);
const optionalAvatarImage = wrapMulter(uploadAvatarImage);

module.exports = {
  optionalPostImage,
  optionalAvatarImage,
  postsDir,
  avatarsDir,
};
