/** 일정: GET/POST /, GET/PATCH/DELETE /:itineraryId (인증 필요) */
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middlewares/authMiddleware');
const itineraryController = require('../controllers/itineraryController');

router.use(authMiddleware);
router.get('/', itineraryController.getAllItineraries);
router.get('/:itineraryId', itineraryController.getItineraryById);
router.post('/', itineraryController.createItinerary);
router.patch('/:itineraryId', itineraryController.updateItinerary);
router.delete('/:itineraryId', itineraryController.deleteItinerary);

module.exports = router;