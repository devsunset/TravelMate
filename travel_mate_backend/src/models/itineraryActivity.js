/**
 * 일정 활동 모델 (itinerary_activities 테이블)
 * 일정의 특정 일차에 대한 활동(시간, 설명, 장소, 좌표)을 저장합니다.
 */

const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const ItineraryDay = require('./itineraryDay');

const ItineraryActivity = sequelize.define('ItineraryActivity', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  itineraryDayId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: ItineraryDay, key: 'id' },
    onDelete: 'CASCADE',
  },
  time: {
    type: DataTypes.STRING, // 예: "09:00 AM", "점심"
    allowNull: true,
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  location: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  coordinates: {
    type: DataTypes.JSON, // { latitude, longitude }
    allowNull: true,
  },
  created_at: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  updated_at: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'itinerary_activities',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
});

ItineraryActivity.belongsTo(ItineraryDay, { foreignKey: 'itineraryDayId' });
ItineraryDay.hasMany(ItineraryActivity, { foreignKey: 'itineraryDayId', as: 'Activities' });

module.exports = ItineraryActivity;
