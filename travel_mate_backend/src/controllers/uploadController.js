/**
 * 이미지 업로드 컨트롤러
 * multer가 저장한 파일 경로를 기준으로 접근 URL을 반환합니다.
 */

/**
 * 서버 기준 이미지 URL 생성 (프로토콜 + 호스트 + 경로)
 */
function getImageUrl(req, relativePath) {
  const base = `${req.protocol}://${req.get('host')}`;
  const pathStr = relativePath.startsWith('/') ? relativePath : `/${relativePath}`;
  return `${base}${pathStr}`;
}

/**
 * 프로필 이미지 업로드 응답
 * 저장은 uploadRoutes의 multer가 수행 (uploads/profile/{userId}/{filename})
 */
exports.uploadProfileImage = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: '이미지 파일이 없습니다.' });
    }
    const relativePath = `/uploads/profile/${req.user.uid}/${req.file.filename}`;
    const imageUrl = getImageUrl(req, relativePath);
    res.status(200).json({ message: '프로필 이미지가 업로드되었습니다.', imageUrl });
  } catch (error) {
    console.error('uploadProfileImage 오류:', error);
    next(error);
  }
};

/**
 * 게시글 이미지 업로드 응답
 */
exports.uploadPostImage = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: '이미지 파일이 없습니다.' });
    }
    const relativePath = `/uploads/posts/${req.user.uid}/${req.file.filename}`;
    const imageUrl = getImageUrl(req, relativePath);
    res.status(200).json({ message: '게시글 이미지가 업로드되었습니다.', imageUrl });
  } catch (error) {
    console.error('uploadPostImage 오류:', error);
    next(error);
  }
};

/**
 * 일정 이미지 업로드 응답
 */
exports.uploadItineraryImage = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: '이미지 파일이 없습니다.' });
    }
    const relativePath = `/uploads/itineraries/${req.user.uid}/${req.file.filename}`;
    const imageUrl = getImageUrl(req, relativePath);
    res.status(200).json({ message: '일정 이미지가 업로드되었습니다.', imageUrl });
  } catch (error) {
    console.error('uploadItineraryImage 오류:', error);
    next(error);
  }
};
