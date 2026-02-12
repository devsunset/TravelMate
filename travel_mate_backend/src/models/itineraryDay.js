/**
 * 일정 일별 모델 (itinerary_days 테이블)
 * 일정 내 하루 단위(일차 번호, 날짜)를 저장합니다.
 */

const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const Itinerary = require('./itinerary');

const ItineraryDay = sequelize.define('ItineraryDay', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  itineraryId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: Itinerary, key: 'id' },
    onDelete: 'CASCADE',
  },
  dayNumber: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  date: {
    type: DataTypes.DATEONLY,
    allowNull: false,
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
  tableName: 'itinerary_days',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  indexes: [{ unique: true, fields: ['itineraryId', 'dayNumber'] }],
});

ItineraryDay.belongsTo(Itinerary, { foreignKey: 'itineraryId' });
Itinerary.hasMany(ItineraryDay, { foreignKey: 'itineraryId', as: 'Days' });

module.exports = ItineraryDay;
