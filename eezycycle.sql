-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Sep 24, 2026 at 06:34 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `eezybooking_eezycycle`
--

-- --------------------------------------------------------

--
-- Table structure for table `article_bookmarks`
--

CREATE TABLE `article_bookmarks` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `article_id` varchar(64) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `article_bookmarks`
--

INSERT INTO `article_bookmarks` (`id`, `user_id`, `article_id`, `created_at`) VALUES
(1, 14, 'sex_desire_cycle_01', '2026-09-24 20:02:18');

-- --------------------------------------------------------

--
-- Table structure for table `comment_likes`
--

CREATE TABLE `comment_likes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `comment_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `comment_likes`
--

INSERT INTO `comment_likes` (`id`, `comment_id`, `user_id`, `created_at`) VALUES
(1, 1, 13, '2026-09-18 21:14:18');

-- --------------------------------------------------------

--
-- Table structure for table `cycles`
--

CREATE TABLE `cycles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `period_length_days` tinyint(4) DEFAULT NULL,
  `cycle_length_days` tinyint(4) DEFAULT NULL,
  `is_predicted` tinyint(1) NOT NULL DEFAULT 0,
  `source` enum('logged','predicted','imported') NOT NULL DEFAULT 'logged',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cycle_observations`
--

CREATE TABLE `cycle_observations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `obs_date` date NOT NULL,
  `observation_type` enum('period','bbt','ovulation_test','cervical_mucus','symptom','pregnancy_test') NOT NULL,
  `value_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`value_json`)),
  `source` varchar(64) NOT NULL DEFAULT 'user',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cycle_observations`
--

INSERT INTO `cycle_observations` (`id`, `user_id`, `obs_date`, `observation_type`, `value_json`, `source`, `created_at`, `updated_at`) VALUES
(66, 8, '2026-08-11', 'period', '{\"logged\":true}', 'user', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(67, 8, '2026-08-12', 'period', '{\"logged\":true}', 'user', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(68, 8, '2026-08-13', 'period', '{\"logged\":true}', 'user', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(69, 8, '2026-08-14', 'period', '{\"logged\":true}', 'user', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(70, 8, '2026-08-15', 'period', '{\"logged\":true}', 'user', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(71, 8, '2026-08-27', 'period', '{\"logged\":true}', 'user', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(72, 8, '2026-08-28', 'period', '{\"logged\":true}', 'user', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(73, 8, '2026-08-29', 'period', '{\"logged\":true}', 'user', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(74, 8, '2026-09-09', 'period', '{\"logged\":true}', 'user', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(75, 8, '2026-09-10', 'period', '{\"logged\":true}', 'user', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(76, 8, '2026-09-11', 'period', '{\"logged\":true}', 'user', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(77, 8, '2026-09-12', 'period', '{\"logged\":true}', 'user', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(78, 8, '2026-09-13', 'period', '{\"logged\":true}', 'user', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(561, 13, '2026-09-18', 'ovulation_test', '{\"result\":\"positive\",\"item_key\":\"ov_positive\"}', 'daily_log', '2026-09-18 21:54:48', '2026-09-18 21:54:48'),
(597, 13, '2026-07-15', 'period', '{\"logged\":true}', 'user', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(598, 13, '2026-07-16', 'period', '{\"logged\":true}', 'user', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(599, 13, '2026-07-17', 'period', '{\"logged\":true}', 'user', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(600, 13, '2026-07-18', 'period', '{\"logged\":true}', 'user', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(601, 13, '2026-07-19', 'period', '{\"logged\":true}', 'user', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(602, 13, '2026-08-19', 'period', '{\"logged\":true}', 'user', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(603, 13, '2026-08-20', 'period', '{\"logged\":true}', 'user', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(604, 13, '2026-08-21', 'period', '{\"logged\":true}', 'user', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(605, 13, '2026-08-22', 'period', '{\"logged\":true}', 'user', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(606, 13, '2026-08-23', 'period', '{\"logged\":true}', 'user', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(607, 13, '2026-09-09', 'period', '{\"logged\":true}', 'user', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(608, 13, '2026-09-10', 'period', '{\"logged\":true}', 'user', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(609, 13, '2026-09-11', 'period', '{\"logged\":true}', 'user', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(610, 13, '2026-09-12', 'period', '{\"logged\":true}', 'user', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(611, 13, '2026-09-13', 'period', '{\"logged\":true}', 'user', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(612, 13, '2026-09-16', 'period', '{\"logged\":true}', 'user', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(613, 13, '2026-09-17', 'period', '{\"logged\":true}', 'user', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(614, 13, '2026-09-18', 'period', '{\"logged\":true}', 'user', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(662, 14, '2026-09-09', 'period', '{\"logged\":true}', 'user', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(663, 14, '2026-09-10', 'period', '{\"logged\":true}', 'user', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(664, 14, '2026-09-11', 'period', '{\"logged\":true}', 'user', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(665, 14, '2026-09-12', 'period', '{\"logged\":true}', 'user', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(666, 14, '2026-09-13', 'period', '{\"logged\":true}', 'user', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(1633, 15, '2026-09-24', 'symptom', '{\"keys\":[\"sym_headache\"]}', 'daily_log', '2026-09-24 21:12:47', '2026-09-24 21:12:47'),
(2026, 15, '2026-08-09', 'period', '{\"logged\":true}', 'user', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(2027, 15, '2026-08-10', 'period', '{\"logged\":true}', 'user', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(2028, 15, '2026-08-11', 'period', '{\"logged\":true}', 'user', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(2029, 15, '2026-08-12', 'period', '{\"logged\":true}', 'user', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(2030, 15, '2026-08-13', 'period', '{\"logged\":true}', 'user', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(2031, 15, '2026-08-14', 'period', '{\"logged\":true}', 'user', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(2032, 15, '2026-08-15', 'period', '{\"logged\":true}', 'user', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(2033, 15, '2026-08-16', 'period', '{\"logged\":true}', 'user', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(2034, 15, '2026-09-09', 'period', '{\"logged\":true}', 'user', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(2035, 15, '2026-09-10', 'period', '{\"logged\":true}', 'user', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(2036, 15, '2026-09-11', 'period', '{\"logged\":true}', 'user', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(2037, 15, '2026-09-12', 'period', '{\"logged\":true}', 'user', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(2038, 15, '2026-09-13', 'period', '{\"logged\":true}', 'user', '2026-09-24 21:14:25', '2026-09-24 21:14:25');

-- --------------------------------------------------------

--
-- Table structure for table `cycle_predictions`
--

CREATE TABLE `cycle_predictions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `pred_date` date NOT NULL,
  `prediction_type` enum('period','ovulation','fertility','pregnancy','none') NOT NULL,
  `day_type` enum('period','ovulation','fertility','pregnancy','none') NOT NULL DEFAULT 'none',
  `period_day` tinyint(4) DEFAULT NULL,
  `range_start` date DEFAULT NULL,
  `range_end` date DEFAULT NULL,
  `confidence` enum('low','medium','high') NOT NULL DEFAULT 'low',
  `confidence_score` decimal(4,3) DEFAULT NULL,
  `evidence_level` char(1) NOT NULL DEFAULT 'A',
  `evidence_sources` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`evidence_sources`)),
  `predicted_value` varchar(64) DEFAULT NULL,
  `headline` varchar(255) DEFAULT NULL,
  `partner_headline` varchar(255) DEFAULT NULL,
  `algorithm_version` varchar(32) NOT NULL DEFAULT 'flo_calendar_v1',
  `generated_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cycle_predictions`
--

INSERT INTO `cycle_predictions` (`id`, `user_id`, `pred_date`, `prediction_type`, `day_type`, `period_day`, `range_start`, `range_end`, `confidence`, `confidence_score`, `evidence_level`, `evidence_sources`, `predicted_value`, `headline`, `partner_headline`, `algorithm_version`, `generated_at`, `updated_at`) VALUES
(3160, 2, '2026-09-09', 'fertility', 'fertility', NULL, '2026-09-09', '2026-09-09', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3161, 2, '2026-09-10', 'fertility', 'fertility', NULL, '2026-09-10', '2026-09-10', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3162, 2, '2026-09-11', 'fertility', 'fertility', NULL, '2026-09-11', '2026-09-11', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3163, 2, '2026-09-12', 'fertility', 'fertility', NULL, '2026-09-12', '2026-09-12', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3164, 2, '2026-09-13', 'fertility', 'fertility', NULL, '2026-09-13', '2026-09-13', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3165, 2, '2026-09-14', 'fertility', 'fertility', NULL, '2026-09-14', '2026-09-14', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3166, 2, '2026-09-15', 'fertility', 'fertility', NULL, '2026-09-15', '2026-09-15', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3167, 2, '2026-09-16', 'fertility', 'fertility', NULL, '2026-09-16', '2026-09-16', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3168, 2, '2026-09-17', 'fertility', 'fertility', NULL, '2026-09-17', '2026-09-17', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3169, 2, '2026-09-18', 'ovulation', 'ovulation', NULL, '2026-09-18', '2026-09-18', 'low', NULL, 'A', NULL, 'ovulation', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3170, 2, '2026-09-19', 'fertility', 'fertility', NULL, '2026-09-19', '2026-09-19', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3171, 2, '2026-09-20', 'fertility', 'fertility', NULL, '2026-09-20', '2026-09-20', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3172, 2, '2026-09-21', 'fertility', 'fertility', NULL, '2026-09-21', '2026-09-21', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3173, 2, '2026-09-22', 'fertility', 'fertility', NULL, '2026-09-22', '2026-09-22', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3174, 2, '2026-10-02', 'period', 'period', 1, '2026-10-02', '2026-10-02', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3175, 2, '2026-10-03', 'period', 'period', 2, '2026-10-03', '2026-10-03', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3176, 2, '2026-10-04', 'period', 'period', 3, '2026-10-04', '2026-10-04', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3177, 2, '2026-10-05', 'period', 'period', 4, '2026-10-05', '2026-10-05', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3178, 2, '2026-10-06', 'period', 'period', 5, '2026-10-06', '2026-10-06', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3179, 2, '2026-10-07', 'fertility', 'fertility', NULL, '2026-10-07', '2026-10-07', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3180, 2, '2026-10-08', 'fertility', 'fertility', NULL, '2026-10-08', '2026-10-08', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3181, 2, '2026-10-09', 'fertility', 'fertility', NULL, '2026-10-09', '2026-10-09', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3182, 2, '2026-10-10', 'fertility', 'fertility', NULL, '2026-10-10', '2026-10-10', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3183, 2, '2026-10-11', 'fertility', 'fertility', NULL, '2026-10-11', '2026-10-11', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3184, 2, '2026-10-12', 'fertility', 'fertility', NULL, '2026-10-12', '2026-10-12', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3185, 2, '2026-10-13', 'fertility', 'fertility', NULL, '2026-10-13', '2026-10-13', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3186, 2, '2026-10-14', 'fertility', 'fertility', NULL, '2026-10-14', '2026-10-14', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3187, 2, '2026-10-15', 'fertility', 'fertility', NULL, '2026-10-15', '2026-10-15', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3188, 2, '2026-10-16', 'ovulation', 'ovulation', NULL, '2026-10-16', '2026-10-16', 'low', NULL, 'A', NULL, 'ovulation', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3189, 2, '2026-10-17', 'fertility', 'fertility', NULL, '2026-10-17', '2026-10-17', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3190, 2, '2026-10-18', 'fertility', 'fertility', NULL, '2026-10-18', '2026-10-18', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3191, 2, '2026-10-19', 'fertility', 'fertility', NULL, '2026-10-19', '2026-10-19', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3192, 2, '2026-10-20', 'fertility', 'fertility', NULL, '2026-10-20', '2026-10-20', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3193, 2, '2026-10-30', 'period', 'period', 1, '2026-10-30', '2026-10-30', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3194, 2, '2026-10-31', 'period', 'period', 2, '2026-10-31', '2026-10-31', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3195, 2, '2026-11-01', 'period', 'period', 3, '2026-11-01', '2026-11-01', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3196, 2, '2026-11-02', 'period', 'period', 4, '2026-11-02', '2026-11-02', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3197, 2, '2026-11-03', 'period', 'period', 5, '2026-11-03', '2026-11-03', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3198, 2, '2026-11-04', 'fertility', 'fertility', NULL, '2026-11-04', '2026-11-04', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3199, 2, '2026-11-05', 'fertility', 'fertility', NULL, '2026-11-05', '2026-11-05', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3200, 2, '2026-11-06', 'fertility', 'fertility', NULL, '2026-11-06', '2026-11-06', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3201, 2, '2026-11-07', 'fertility', 'fertility', NULL, '2026-11-07', '2026-11-07', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3202, 2, '2026-11-08', 'fertility', 'fertility', NULL, '2026-11-08', '2026-11-08', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3203, 2, '2026-11-09', 'fertility', 'fertility', NULL, '2026-11-09', '2026-11-09', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3204, 2, '2026-11-10', 'fertility', 'fertility', NULL, '2026-11-10', '2026-11-10', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3205, 2, '2026-11-11', 'fertility', 'fertility', NULL, '2026-11-11', '2026-11-11', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3206, 2, '2026-11-12', 'fertility', 'fertility', NULL, '2026-11-12', '2026-11-12', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3207, 2, '2026-11-13', 'ovulation', 'ovulation', NULL, '2026-11-13', '2026-11-13', 'low', NULL, 'A', NULL, 'ovulation', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3208, 2, '2026-11-14', 'fertility', 'fertility', NULL, '2026-11-14', '2026-11-14', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3209, 2, '2026-11-15', 'fertility', 'fertility', NULL, '2026-11-15', '2026-11-15', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3210, 2, '2026-11-16', 'fertility', 'fertility', NULL, '2026-11-16', '2026-11-16', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3211, 2, '2026-11-17', 'fertility', 'fertility', NULL, '2026-11-17', '2026-11-17', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3212, 2, '2026-11-27', 'period', 'period', 1, '2026-11-27', '2026-11-27', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3213, 2, '2026-11-28', 'period', 'period', 2, '2026-11-28', '2026-11-28', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3214, 2, '2026-11-29', 'period', 'period', 3, '2026-11-29', '2026-11-29', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3215, 2, '2026-11-30', 'period', 'period', 4, '2026-11-30', '2026-11-30', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3216, 2, '2026-12-01', 'period', 'period', 5, '2026-12-01', '2026-12-01', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3217, 2, '2026-12-02', 'fertility', 'fertility', NULL, '2026-12-02', '2026-12-02', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3218, 2, '2026-12-03', 'fertility', 'fertility', NULL, '2026-12-03', '2026-12-03', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3219, 2, '2026-12-04', 'fertility', 'fertility', NULL, '2026-12-04', '2026-12-04', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3220, 2, '2026-12-05', 'fertility', 'fertility', NULL, '2026-12-05', '2026-12-05', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3221, 2, '2026-12-06', 'fertility', 'fertility', NULL, '2026-12-06', '2026-12-06', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3222, 2, '2026-12-07', 'fertility', 'fertility', NULL, '2026-12-07', '2026-12-07', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3223, 2, '2026-12-08', 'fertility', 'fertility', NULL, '2026-12-08', '2026-12-08', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3224, 2, '2026-12-09', 'fertility', 'fertility', NULL, '2026-12-09', '2026-12-09', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3225, 2, '2026-12-10', 'fertility', 'fertility', NULL, '2026-12-10', '2026-12-10', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3226, 2, '2026-12-11', 'ovulation', 'ovulation', NULL, '2026-12-11', '2026-12-11', 'low', NULL, 'A', NULL, 'ovulation', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3227, 2, '2026-12-12', 'fertility', 'fertility', NULL, '2026-12-12', '2026-12-12', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3228, 2, '2026-12-13', 'fertility', 'fertility', NULL, '2026-12-13', '2026-12-13', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3229, 2, '2026-12-14', 'fertility', 'fertility', NULL, '2026-12-14', '2026-12-14', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3230, 2, '2026-12-15', 'fertility', 'fertility', NULL, '2026-12-15', '2026-12-15', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3231, 2, '2026-12-25', 'period', 'period', 1, '2026-12-25', '2026-12-25', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3232, 2, '2026-12-26', 'period', 'period', 2, '2026-12-26', '2026-12-26', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3233, 2, '2026-12-27', 'period', 'period', 3, '2026-12-27', '2026-12-27', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3234, 2, '2026-12-28', 'period', 'period', 4, '2026-12-28', '2026-12-28', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3235, 2, '2026-12-29', 'period', 'period', 5, '2026-12-29', '2026-12-29', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3236, 2, '2026-12-30', 'fertility', 'fertility', NULL, '2026-12-30', '2026-12-30', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3237, 2, '2026-12-31', 'fertility', 'fertility', NULL, '2026-12-31', '2026-12-31', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3238, 2, '2027-01-01', 'fertility', 'fertility', NULL, '2027-01-01', '2027-01-01', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3239, 2, '2027-01-02', 'fertility', 'fertility', NULL, '2027-01-02', '2027-01-02', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3240, 2, '2027-01-03', 'fertility', 'fertility', NULL, '2027-01-03', '2027-01-03', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3241, 2, '2027-01-04', 'fertility', 'fertility', NULL, '2027-01-04', '2027-01-04', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3242, 2, '2027-01-05', 'fertility', 'fertility', NULL, '2027-01-05', '2027-01-05', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3243, 2, '2027-01-06', 'fertility', 'fertility', NULL, '2027-01-06', '2027-01-06', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3244, 2, '2027-01-07', 'fertility', 'fertility', NULL, '2027-01-07', '2027-01-07', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3245, 2, '2027-01-08', 'ovulation', 'ovulation', NULL, '2027-01-08', '2027-01-08', 'low', NULL, 'A', NULL, 'ovulation', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3246, 2, '2027-01-09', 'fertility', 'fertility', NULL, '2027-01-09', '2027-01-09', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3247, 2, '2027-01-10', 'fertility', 'fertility', NULL, '2027-01-10', '2027-01-10', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3248, 2, '2027-01-11', 'fertility', 'fertility', NULL, '2027-01-11', '2027-01-11', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3249, 2, '2027-01-12', 'fertility', 'fertility', NULL, '2027-01-12', '2027-01-12', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3250, 2, '2027-01-22', 'period', 'period', 1, '2027-01-22', '2027-01-22', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3251, 2, '2027-01-23', 'period', 'period', 2, '2027-01-23', '2027-01-23', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3252, 2, '2027-01-24', 'period', 'period', 3, '2027-01-24', '2027-01-24', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3253, 2, '2027-01-25', 'period', 'period', 4, '2027-01-25', '2027-01-25', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3254, 2, '2027-01-26', 'period', 'period', 5, '2027-01-26', '2027-01-26', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3255, 2, '2027-01-27', 'fertility', 'fertility', NULL, '2027-01-27', '2027-01-27', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3256, 2, '2027-01-28', 'fertility', 'fertility', NULL, '2027-01-28', '2027-01-28', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3257, 2, '2027-01-29', 'fertility', 'fertility', NULL, '2027-01-29', '2027-01-29', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3258, 2, '2027-01-30', 'fertility', 'fertility', NULL, '2027-01-30', '2027-01-30', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3259, 2, '2027-01-31', 'fertility', 'fertility', NULL, '2027-01-31', '2027-01-31', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3260, 2, '2027-02-01', 'fertility', 'fertility', NULL, '2027-02-01', '2027-02-01', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3261, 2, '2027-02-02', 'fertility', 'fertility', NULL, '2027-02-02', '2027-02-02', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3262, 2, '2027-02-03', 'fertility', 'fertility', NULL, '2027-02-03', '2027-02-03', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3263, 2, '2027-02-04', 'fertility', 'fertility', NULL, '2027-02-04', '2027-02-04', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3264, 2, '2027-02-05', 'ovulation', 'ovulation', NULL, '2027-02-05', '2027-02-05', 'low', NULL, 'A', NULL, 'ovulation', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3265, 2, '2027-02-06', 'fertility', 'fertility', NULL, '2027-02-06', '2027-02-06', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3266, 2, '2027-02-07', 'fertility', 'fertility', NULL, '2027-02-07', '2027-02-07', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3267, 2, '2027-02-08', 'fertility', 'fertility', NULL, '2027-02-08', '2027-02-08', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3268, 2, '2027-02-09', 'fertility', 'fertility', NULL, '2027-02-09', '2027-02-09', 'low', NULL, 'A', NULL, 'fertility', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3269, 2, '2027-02-19', 'period', 'period', 1, '2027-02-19', '2027-02-19', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3270, 2, '2027-02-20', 'period', 'period', 2, '2027-02-20', '2027-02-20', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3271, 2, '2027-02-21', 'period', 'period', 3, '2027-02-21', '2027-02-21', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3272, 2, '2027-02-22', 'period', 'period', 4, '2027-02-22', '2027-02-22', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3273, 2, '2027-02-23', 'period', 'period', 5, '2027-02-23', '2027-02-23', 'low', NULL, 'A', NULL, 'period', NULL, NULL, 'ecc_prediction_v1', '2026-09-16 19:10:05', '2026-09-16 20:13:17'),
(3406, 8, '2026-10-07', 'period', 'period', 1, '2026-10-04', '2026-10-10', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3407, 8, '2026-10-08', 'period', 'period', 2, '2026-10-05', '2026-10-11', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3408, 8, '2026-10-09', 'period', 'period', 3, '2026-10-06', '2026-10-12', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3409, 8, '2026-10-10', 'period', 'period', 4, '2026-10-07', '2026-10-13', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3410, 8, '2026-11-04', 'period', 'period', 1, '2026-11-01', '2026-11-07', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3411, 8, '2026-11-05', 'period', 'period', 2, '2026-11-02', '2026-11-08', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3412, 8, '2026-11-06', 'period', 'period', 3, '2026-11-03', '2026-11-09', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3413, 8, '2026-11-07', 'period', 'period', 4, '2026-11-04', '2026-11-10', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3414, 8, '2026-12-02', 'period', 'period', 1, '2026-11-29', '2026-12-05', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3415, 8, '2026-12-03', 'period', 'period', 2, '2026-11-30', '2026-12-06', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3416, 8, '2026-12-04', 'period', 'period', 3, '2026-12-01', '2026-12-07', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3417, 8, '2026-12-05', 'period', 'period', 4, '2026-12-02', '2026-12-08', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3418, 8, '2026-12-30', 'period', 'period', 1, '2026-12-27', '2027-01-02', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3419, 8, '2026-12-31', 'period', 'period', 2, '2026-12-28', '2027-01-03', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3420, 8, '2027-01-01', 'period', 'period', 3, '2026-12-29', '2027-01-04', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3421, 8, '2027-01-02', 'period', 'period', 4, '2026-12-30', '2027-01-05', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3422, 8, '2027-01-27', 'period', 'period', 1, '2027-01-24', '2027-01-30', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3423, 8, '2027-01-28', 'period', 'period', 2, '2027-01-25', '2027-01-31', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3424, 8, '2027-01-29', 'period', 'period', 3, '2027-01-26', '2027-02-01', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3425, 8, '2027-01-30', 'period', 'period', 4, '2027-01-27', '2027-02-02', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3426, 8, '2027-02-24', 'period', 'period', 1, '2027-02-21', '2027-02-27', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3427, 8, '2027-02-25', 'period', 'period', 2, '2027-02-22', '2027-02-28', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3428, 8, '2027-02-26', 'period', 'period', 3, '2027-02-23', '2027-03-01', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3429, 8, '2027-02-27', 'period', 'period', 4, '2027-02-24', '2027-03-02', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3430, 8, '2026-09-23', 'ovulation', 'ovulation', NULL, '2026-09-21', '2026-09-25', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3431, 8, '2026-10-21', 'ovulation', 'ovulation', NULL, '2026-10-19', '2026-10-23', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3432, 8, '2026-11-18', 'ovulation', 'ovulation', NULL, '2026-11-16', '2026-11-20', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3433, 8, '2026-12-16', 'ovulation', 'ovulation', NULL, '2026-12-14', '2026-12-18', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3434, 8, '2027-01-13', 'ovulation', 'ovulation', NULL, '2027-01-11', '2027-01-15', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3435, 8, '2027-02-10', 'ovulation', 'ovulation', NULL, '2027-02-08', '2027-02-12', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3436, 8, '2026-09-18', 'fertility', 'fertility', NULL, '2026-09-18', '2026-09-24', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3437, 8, '2026-09-19', 'fertility', 'fertility', NULL, '2026-09-18', '2026-09-24', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3438, 8, '2026-09-20', 'fertility', 'fertility', NULL, '2026-09-18', '2026-09-24', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3439, 8, '2026-09-21', 'fertility', 'fertility', NULL, '2026-09-18', '2026-09-24', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3440, 8, '2026-09-22', 'fertility', 'fertility', NULL, '2026-09-18', '2026-09-24', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3441, 8, '2026-09-24', 'fertility', 'fertility', NULL, '2026-09-18', '2026-09-24', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3442, 8, '2026-10-16', 'fertility', 'fertility', NULL, '2026-10-16', '2026-10-22', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3443, 8, '2026-10-17', 'fertility', 'fertility', NULL, '2026-10-16', '2026-10-22', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3444, 8, '2026-10-18', 'fertility', 'fertility', NULL, '2026-10-16', '2026-10-22', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3445, 8, '2026-10-19', 'fertility', 'fertility', NULL, '2026-10-16', '2026-10-22', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3446, 8, '2026-10-20', 'fertility', 'fertility', NULL, '2026-10-16', '2026-10-22', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3447, 8, '2026-10-22', 'fertility', 'fertility', NULL, '2026-10-16', '2026-10-22', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3448, 8, '2026-11-13', 'fertility', 'fertility', NULL, '2026-11-13', '2026-11-19', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3449, 8, '2026-11-14', 'fertility', 'fertility', NULL, '2026-11-13', '2026-11-19', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3450, 8, '2026-11-15', 'fertility', 'fertility', NULL, '2026-11-13', '2026-11-19', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3451, 8, '2026-11-16', 'fertility', 'fertility', NULL, '2026-11-13', '2026-11-19', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3452, 8, '2026-11-17', 'fertility', 'fertility', NULL, '2026-11-13', '2026-11-19', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3453, 8, '2026-11-19', 'fertility', 'fertility', NULL, '2026-11-13', '2026-11-19', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3454, 8, '2026-12-11', 'fertility', 'fertility', NULL, '2026-12-11', '2026-12-17', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3455, 8, '2026-12-12', 'fertility', 'fertility', NULL, '2026-12-11', '2026-12-17', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3456, 8, '2026-12-13', 'fertility', 'fertility', NULL, '2026-12-11', '2026-12-17', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3457, 8, '2026-12-14', 'fertility', 'fertility', NULL, '2026-12-11', '2026-12-17', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3458, 8, '2026-12-15', 'fertility', 'fertility', NULL, '2026-12-11', '2026-12-17', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3459, 8, '2026-12-17', 'fertility', 'fertility', NULL, '2026-12-11', '2026-12-17', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3460, 8, '2027-01-08', 'fertility', 'fertility', NULL, '2027-01-08', '2027-01-14', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3461, 8, '2027-01-09', 'fertility', 'fertility', NULL, '2027-01-08', '2027-01-14', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3462, 8, '2027-01-10', 'fertility', 'fertility', NULL, '2027-01-08', '2027-01-14', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3463, 8, '2027-01-11', 'fertility', 'fertility', NULL, '2027-01-08', '2027-01-14', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3464, 8, '2027-01-12', 'fertility', 'fertility', NULL, '2027-01-08', '2027-01-14', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3465, 8, '2027-01-14', 'fertility', 'fertility', NULL, '2027-01-08', '2027-01-14', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3466, 8, '2027-02-05', 'fertility', 'fertility', NULL, '2027-02-05', '2027-02-11', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3467, 8, '2027-02-06', 'fertility', 'fertility', NULL, '2027-02-05', '2027-02-11', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3468, 8, '2027-02-07', 'fertility', 'fertility', NULL, '2027-02-05', '2027-02-11', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3469, 8, '2027-02-08', 'fertility', 'fertility', NULL, '2027-02-05', '2027-02-11', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3470, 8, '2027-02-09', 'fertility', 'fertility', NULL, '2027-02-05', '2027-02-11', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(3471, 8, '2027-02-11', 'fertility', 'fertility', NULL, '2027-02-05', '2027-02-11', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(4583, 13, '2026-10-14', 'period', 'period', 1, '2026-10-10', '2026-10-18', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4584, 13, '2026-10-15', 'period', 'period', 2, '2026-10-11', '2026-10-19', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4585, 13, '2026-10-16', 'period', 'period', 3, '2026-10-12', '2026-10-20', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4586, 13, '2026-10-17', 'period', 'period', 4, '2026-10-13', '2026-10-21', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4587, 13, '2026-10-18', 'period', 'period', 5, '2026-10-14', '2026-10-22', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4588, 13, '2026-11-11', 'period', 'period', 1, '2026-11-07', '2026-11-15', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4589, 13, '2026-11-12', 'period', 'period', 2, '2026-11-08', '2026-11-16', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4590, 13, '2026-11-13', 'period', 'period', 3, '2026-11-09', '2026-11-17', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4591, 13, '2026-11-14', 'period', 'period', 4, '2026-11-10', '2026-11-18', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4592, 13, '2026-11-15', 'period', 'period', 5, '2026-11-11', '2026-11-19', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4593, 13, '2026-12-09', 'period', 'period', 1, '2026-12-05', '2026-12-13', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4594, 13, '2026-12-10', 'period', 'period', 2, '2026-12-06', '2026-12-14', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4595, 13, '2026-12-11', 'period', 'period', 3, '2026-12-07', '2026-12-15', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4596, 13, '2026-12-12', 'period', 'period', 4, '2026-12-08', '2026-12-16', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4597, 13, '2026-12-13', 'period', 'period', 5, '2026-12-09', '2026-12-17', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4598, 13, '2027-01-06', 'period', 'period', 1, '2027-01-02', '2027-01-10', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4599, 13, '2027-01-07', 'period', 'period', 2, '2027-01-03', '2027-01-11', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4600, 13, '2027-01-08', 'period', 'period', 3, '2027-01-04', '2027-01-12', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4601, 13, '2027-01-09', 'period', 'period', 4, '2027-01-05', '2027-01-13', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4602, 13, '2027-01-10', 'period', 'period', 5, '2027-01-06', '2027-01-14', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4603, 13, '2027-02-03', 'period', 'period', 1, '2027-01-30', '2027-02-07', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4604, 13, '2027-02-04', 'period', 'period', 2, '2027-01-31', '2027-02-08', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4605, 13, '2027-02-05', 'period', 'period', 3, '2027-02-01', '2027-02-09', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4606, 13, '2027-02-06', 'period', 'period', 4, '2027-02-02', '2027-02-10', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4607, 13, '2027-02-07', 'period', 'period', 5, '2027-02-03', '2027-02-11', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4608, 13, '2027-03-03', 'period', 'period', 1, '2027-02-27', '2027-03-07', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4609, 13, '2027-03-04', 'period', 'period', 2, '2027-02-28', '2027-03-08', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4610, 13, '2027-03-05', 'period', 'period', 3, '2027-03-01', '2027-03-09', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4611, 13, '2027-03-06', 'period', 'period', 4, '2027-03-02', '2027-03-10', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4612, 13, '2027-03-07', 'period', 'period', 5, '2027-03-03', '2027-03-11', 'medium', 0.420, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4613, 13, '2026-09-23', 'ovulation', 'ovulation', NULL, '2026-09-21', '2026-09-25', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4614, 13, '2026-09-30', 'ovulation', 'ovulation', NULL, '2026-09-28', '2026-10-02', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4615, 13, '2026-10-28', 'ovulation', 'ovulation', NULL, '2026-10-26', '2026-10-30', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4616, 13, '2026-11-25', 'ovulation', 'ovulation', NULL, '2026-11-23', '2026-11-27', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4617, 13, '2026-12-23', 'ovulation', 'ovulation', NULL, '2026-12-21', '2026-12-25', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4618, 13, '2027-01-20', 'ovulation', 'ovulation', NULL, '2027-01-18', '2027-01-22', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4619, 13, '2027-02-17', 'ovulation', 'ovulation', NULL, '2027-02-15', '2027-02-19', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4620, 13, '2026-09-19', 'fertility', 'fertility', NULL, '2026-09-18', '2026-09-24', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4621, 13, '2026-09-20', 'fertility', 'fertility', NULL, '2026-09-18', '2026-09-24', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4622, 13, '2026-09-21', 'fertility', 'fertility', NULL, '2026-09-18', '2026-09-24', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4623, 13, '2026-09-22', 'fertility', 'fertility', NULL, '2026-09-18', '2026-09-24', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44');
INSERT INTO `cycle_predictions` (`id`, `user_id`, `pred_date`, `prediction_type`, `day_type`, `period_day`, `range_start`, `range_end`, `confidence`, `confidence_score`, `evidence_level`, `evidence_sources`, `predicted_value`, `headline`, `partner_headline`, `algorithm_version`, `generated_at`, `updated_at`) VALUES
(4624, 13, '2026-09-24', 'fertility', 'fertility', NULL, '2026-09-18', '2026-09-24', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4625, 13, '2026-09-25', 'fertility', 'fertility', NULL, '2026-09-25', '2026-10-01', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4626, 13, '2026-09-26', 'fertility', 'fertility', NULL, '2026-09-25', '2026-10-01', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4627, 13, '2026-09-27', 'fertility', 'fertility', NULL, '2026-09-25', '2026-10-01', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4628, 13, '2026-09-28', 'fertility', 'fertility', NULL, '2026-09-25', '2026-10-01', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4629, 13, '2026-09-29', 'fertility', 'fertility', NULL, '2026-09-25', '2026-10-01', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4630, 13, '2026-10-01', 'fertility', 'fertility', NULL, '2026-09-25', '2026-10-01', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4631, 13, '2026-10-23', 'fertility', 'fertility', NULL, '2026-10-23', '2026-10-29', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4632, 13, '2026-10-24', 'fertility', 'fertility', NULL, '2026-10-23', '2026-10-29', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4633, 13, '2026-10-25', 'fertility', 'fertility', NULL, '2026-10-23', '2026-10-29', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4634, 13, '2026-10-26', 'fertility', 'fertility', NULL, '2026-10-23', '2026-10-29', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4635, 13, '2026-10-27', 'fertility', 'fertility', NULL, '2026-10-23', '2026-10-29', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4636, 13, '2026-10-29', 'fertility', 'fertility', NULL, '2026-10-23', '2026-10-29', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4637, 13, '2026-11-20', 'fertility', 'fertility', NULL, '2026-11-20', '2026-11-26', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4638, 13, '2026-11-21', 'fertility', 'fertility', NULL, '2026-11-20', '2026-11-26', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4639, 13, '2026-11-22', 'fertility', 'fertility', NULL, '2026-11-20', '2026-11-26', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4640, 13, '2026-11-23', 'fertility', 'fertility', NULL, '2026-11-20', '2026-11-26', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4641, 13, '2026-11-24', 'fertility', 'fertility', NULL, '2026-11-20', '2026-11-26', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4642, 13, '2026-11-26', 'fertility', 'fertility', NULL, '2026-11-20', '2026-11-26', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4643, 13, '2026-12-18', 'fertility', 'fertility', NULL, '2026-12-18', '2026-12-24', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4644, 13, '2026-12-19', 'fertility', 'fertility', NULL, '2026-12-18', '2026-12-24', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4645, 13, '2026-12-20', 'fertility', 'fertility', NULL, '2026-12-18', '2026-12-24', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4646, 13, '2026-12-21', 'fertility', 'fertility', NULL, '2026-12-18', '2026-12-24', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4647, 13, '2026-12-22', 'fertility', 'fertility', NULL, '2026-12-18', '2026-12-24', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4648, 13, '2026-12-24', 'fertility', 'fertility', NULL, '2026-12-18', '2026-12-24', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4649, 13, '2027-01-15', 'fertility', 'fertility', NULL, '2027-01-15', '2027-01-21', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4650, 13, '2027-01-16', 'fertility', 'fertility', NULL, '2027-01-15', '2027-01-21', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4651, 13, '2027-01-17', 'fertility', 'fertility', NULL, '2027-01-15', '2027-01-21', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4652, 13, '2027-01-18', 'fertility', 'fertility', NULL, '2027-01-15', '2027-01-21', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4653, 13, '2027-01-19', 'fertility', 'fertility', NULL, '2027-01-15', '2027-01-21', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4654, 13, '2027-01-21', 'fertility', 'fertility', NULL, '2027-01-15', '2027-01-21', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4655, 13, '2027-02-12', 'fertility', 'fertility', NULL, '2027-02-12', '2027-02-18', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4656, 13, '2027-02-13', 'fertility', 'fertility', NULL, '2027-02-12', '2027-02-18', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4657, 13, '2027-02-14', 'fertility', 'fertility', NULL, '2027-02-12', '2027-02-18', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4658, 13, '2027-02-15', 'fertility', 'fertility', NULL, '2027-02-12', '2027-02-18', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4659, 13, '2027-02-16', 'fertility', 'fertility', NULL, '2027-02-12', '2027-02-18', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4660, 13, '2027-02-18', 'fertility', 'fertility', NULL, '2027-02-12', '2027-02-18', 'medium', 0.420, 'C', '[\"historical_cycle_data\",\"weighted_cycle_statistics\",\"ovulation_test_lh\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(4949, 14, '2026-10-07', 'period', 'period', 1, '2026-10-04', '2026-10-10', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4950, 14, '2026-10-08', 'period', 'period', 2, '2026-10-05', '2026-10-11', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4951, 14, '2026-10-09', 'period', 'period', 3, '2026-10-06', '2026-10-12', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4952, 14, '2026-10-10', 'period', 'period', 4, '2026-10-07', '2026-10-13', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4953, 14, '2026-10-11', 'period', 'period', 5, '2026-10-08', '2026-10-14', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4954, 14, '2026-11-04', 'period', 'period', 1, '2026-11-01', '2026-11-07', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4955, 14, '2026-11-05', 'period', 'period', 2, '2026-11-02', '2026-11-08', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4956, 14, '2026-11-06', 'period', 'period', 3, '2026-11-03', '2026-11-09', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4957, 14, '2026-11-07', 'period', 'period', 4, '2026-11-04', '2026-11-10', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4958, 14, '2026-11-08', 'period', 'period', 5, '2026-11-05', '2026-11-11', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4959, 14, '2026-12-02', 'period', 'period', 1, '2026-11-29', '2026-12-05', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4960, 14, '2026-12-03', 'period', 'period', 2, '2026-11-30', '2026-12-06', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4961, 14, '2026-12-04', 'period', 'period', 3, '2026-12-01', '2026-12-07', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4962, 14, '2026-12-05', 'period', 'period', 4, '2026-12-02', '2026-12-08', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4963, 14, '2026-12-06', 'period', 'period', 5, '2026-12-03', '2026-12-09', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4964, 14, '2026-12-30', 'period', 'period', 1, '2026-12-27', '2027-01-02', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4965, 14, '2026-12-31', 'period', 'period', 2, '2026-12-28', '2027-01-03', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4966, 14, '2027-01-01', 'period', 'period', 3, '2026-12-29', '2027-01-04', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4967, 14, '2027-01-02', 'period', 'period', 4, '2026-12-30', '2027-01-05', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4968, 14, '2027-01-03', 'period', 'period', 5, '2026-12-31', '2027-01-06', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4969, 14, '2027-01-27', 'period', 'period', 1, '2027-01-24', '2027-01-30', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4970, 14, '2027-01-28', 'period', 'period', 2, '2027-01-25', '2027-01-31', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4971, 14, '2027-01-29', 'period', 'period', 3, '2027-01-26', '2027-02-01', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4972, 14, '2027-01-30', 'period', 'period', 4, '2027-01-27', '2027-02-02', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4973, 14, '2027-01-31', 'period', 'period', 5, '2027-01-28', '2027-02-03', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4974, 14, '2027-02-24', 'period', 'period', 1, '2027-02-21', '2027-02-27', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4975, 14, '2027-02-25', 'period', 'period', 2, '2027-02-22', '2027-02-28', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4976, 14, '2027-02-26', 'period', 'period', 3, '2027-02-23', '2027-03-01', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4977, 14, '2027-02-27', 'period', 'period', 4, '2027-02-24', '2027-03-02', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4978, 14, '2027-02-28', 'period', 'period', 5, '2027-02-25', '2027-03-03', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4979, 14, '2026-09-23', 'ovulation', 'ovulation', NULL, '2026-09-21', '2026-09-25', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4980, 14, '2026-10-21', 'ovulation', 'ovulation', NULL, '2026-10-19', '2026-10-23', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4981, 14, '2026-11-18', 'ovulation', 'ovulation', NULL, '2026-11-16', '2026-11-20', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4982, 14, '2026-12-16', 'ovulation', 'ovulation', NULL, '2026-12-14', '2026-12-18', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4983, 14, '2027-01-13', 'ovulation', 'ovulation', NULL, '2027-01-11', '2027-01-15', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4984, 14, '2027-02-10', 'ovulation', 'ovulation', NULL, '2027-02-08', '2027-02-12', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4985, 14, '2026-09-18', 'fertility', 'fertility', NULL, '2026-09-18', '2026-09-24', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4986, 14, '2026-09-19', 'fertility', 'fertility', NULL, '2026-09-18', '2026-09-24', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4987, 14, '2026-09-20', 'fertility', 'fertility', NULL, '2026-09-18', '2026-09-24', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4988, 14, '2026-09-21', 'fertility', 'fertility', NULL, '2026-09-18', '2026-09-24', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4989, 14, '2026-09-22', 'fertility', 'fertility', NULL, '2026-09-18', '2026-09-24', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4990, 14, '2026-09-24', 'fertility', 'fertility', NULL, '2026-09-18', '2026-09-24', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4991, 14, '2026-10-16', 'fertility', 'fertility', NULL, '2026-10-16', '2026-10-22', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4992, 14, '2026-10-17', 'fertility', 'fertility', NULL, '2026-10-16', '2026-10-22', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4993, 14, '2026-10-18', 'fertility', 'fertility', NULL, '2026-10-16', '2026-10-22', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4994, 14, '2026-10-19', 'fertility', 'fertility', NULL, '2026-10-16', '2026-10-22', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4995, 14, '2026-10-20', 'fertility', 'fertility', NULL, '2026-10-16', '2026-10-22', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4996, 14, '2026-10-22', 'fertility', 'fertility', NULL, '2026-10-16', '2026-10-22', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4997, 14, '2026-11-13', 'fertility', 'fertility', NULL, '2026-11-13', '2026-11-19', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4998, 14, '2026-11-14', 'fertility', 'fertility', NULL, '2026-11-13', '2026-11-19', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(4999, 14, '2026-11-15', 'fertility', 'fertility', NULL, '2026-11-13', '2026-11-19', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5000, 14, '2026-11-16', 'fertility', 'fertility', NULL, '2026-11-13', '2026-11-19', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5001, 14, '2026-11-17', 'fertility', 'fertility', NULL, '2026-11-13', '2026-11-19', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5002, 14, '2026-11-19', 'fertility', 'fertility', NULL, '2026-11-13', '2026-11-19', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5003, 14, '2026-12-11', 'fertility', 'fertility', NULL, '2026-12-11', '2026-12-17', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5004, 14, '2026-12-12', 'fertility', 'fertility', NULL, '2026-12-11', '2026-12-17', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5005, 14, '2026-12-13', 'fertility', 'fertility', NULL, '2026-12-11', '2026-12-17', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5006, 14, '2026-12-14', 'fertility', 'fertility', NULL, '2026-12-11', '2026-12-17', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5007, 14, '2026-12-15', 'fertility', 'fertility', NULL, '2026-12-11', '2026-12-17', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5008, 14, '2026-12-17', 'fertility', 'fertility', NULL, '2026-12-11', '2026-12-17', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5009, 14, '2027-01-08', 'fertility', 'fertility', NULL, '2027-01-08', '2027-01-14', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5010, 14, '2027-01-09', 'fertility', 'fertility', NULL, '2027-01-08', '2027-01-14', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5011, 14, '2027-01-10', 'fertility', 'fertility', NULL, '2027-01-08', '2027-01-14', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5012, 14, '2027-01-11', 'fertility', 'fertility', NULL, '2027-01-08', '2027-01-14', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5013, 14, '2027-01-12', 'fertility', 'fertility', NULL, '2027-01-08', '2027-01-14', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5014, 14, '2027-01-14', 'fertility', 'fertility', NULL, '2027-01-08', '2027-01-14', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5015, 14, '2027-02-05', 'fertility', 'fertility', NULL, '2027-02-05', '2027-02-11', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5016, 14, '2027-02-06', 'fertility', 'fertility', NULL, '2027-02-05', '2027-02-11', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5017, 14, '2027-02-07', 'fertility', 'fertility', NULL, '2027-02-05', '2027-02-11', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5018, 14, '2027-02-08', 'fertility', 'fertility', NULL, '2027-02-05', '2027-02-11', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5019, 14, '2027-02-09', 'fertility', 'fertility', NULL, '2027-02-05', '2027-02-11', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(5020, 14, '2027-02-11', 'fertility', 'fertility', NULL, '2027-02-05', '2027-02-11', 'low', 0.325, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(8549, 15, '2026-10-10', 'period', 'period', 1, '2026-10-07', '2026-10-13', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8550, 15, '2026-10-11', 'period', 'period', 2, '2026-10-08', '2026-10-14', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8551, 15, '2026-10-12', 'period', 'period', 3, '2026-10-09', '2026-10-15', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8552, 15, '2026-10-13', 'period', 'period', 4, '2026-10-10', '2026-10-16', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8553, 15, '2026-10-14', 'period', 'period', 5, '2026-10-11', '2026-10-17', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8554, 15, '2026-11-10', 'period', 'period', 1, '2026-11-07', '2026-11-13', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8555, 15, '2026-11-11', 'period', 'period', 2, '2026-11-08', '2026-11-14', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8556, 15, '2026-11-12', 'period', 'period', 3, '2026-11-09', '2026-11-15', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8557, 15, '2026-11-13', 'period', 'period', 4, '2026-11-10', '2026-11-16', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8558, 15, '2026-11-14', 'period', 'period', 5, '2026-11-11', '2026-11-17', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8559, 15, '2026-12-11', 'period', 'period', 1, '2026-12-08', '2026-12-14', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8560, 15, '2026-12-12', 'period', 'period', 2, '2026-12-09', '2026-12-15', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8561, 15, '2026-12-13', 'period', 'period', 3, '2026-12-10', '2026-12-16', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8562, 15, '2026-12-14', 'period', 'period', 4, '2026-12-11', '2026-12-17', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8563, 15, '2026-12-15', 'period', 'period', 5, '2026-12-12', '2026-12-18', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8564, 15, '2027-01-11', 'period', 'period', 1, '2027-01-08', '2027-01-14', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8565, 15, '2027-01-12', 'period', 'period', 2, '2027-01-09', '2027-01-15', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8566, 15, '2027-01-13', 'period', 'period', 3, '2027-01-10', '2027-01-16', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8567, 15, '2027-01-14', 'period', 'period', 4, '2027-01-11', '2027-01-17', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8568, 15, '2027-01-15', 'period', 'period', 5, '2027-01-12', '2027-01-18', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8569, 15, '2027-02-11', 'period', 'period', 1, '2027-02-08', '2027-02-14', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8570, 15, '2027-02-12', 'period', 'period', 2, '2027-02-09', '2027-02-15', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8571, 15, '2027-02-13', 'period', 'period', 3, '2027-02-10', '2027-02-16', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8572, 15, '2027-02-14', 'period', 'period', 4, '2027-02-11', '2027-02-17', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8573, 15, '2027-02-15', 'period', 'period', 5, '2027-02-12', '2027-02-18', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8574, 15, '2027-03-14', 'period', 'period', 1, '2027-03-11', '2027-03-17', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8575, 15, '2027-03-15', 'period', 'period', 2, '2027-03-12', '2027-03-18', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8576, 15, '2027-03-16', 'period', 'period', 3, '2027-03-13', '2027-03-19', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8577, 15, '2027-03-17', 'period', 'period', 4, '2027-03-14', '2027-03-20', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8578, 15, '2027-03-18', 'period', 'period', 5, '2027-03-15', '2027-03-21', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'period', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8579, 15, '2026-09-26', 'ovulation', 'ovulation', NULL, '2026-09-24', '2026-09-28', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8580, 15, '2026-10-27', 'ovulation', 'ovulation', NULL, '2026-10-25', '2026-10-29', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8581, 15, '2026-11-27', 'ovulation', 'ovulation', NULL, '2026-11-25', '2026-11-29', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8582, 15, '2026-12-28', 'ovulation', 'ovulation', NULL, '2026-12-26', '2026-12-30', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8583, 15, '2027-01-28', 'ovulation', 'ovulation', NULL, '2027-01-26', '2027-01-30', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8584, 15, '2027-02-28', 'ovulation', 'ovulation', NULL, '2027-02-26', '2027-03-02', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'ovulation', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8585, 15, '2026-09-21', 'fertility', 'fertility', NULL, '2026-09-21', '2026-09-27', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8586, 15, '2026-09-22', 'fertility', 'fertility', NULL, '2026-09-21', '2026-09-27', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8587, 15, '2026-09-23', 'fertility', 'fertility', NULL, '2026-09-21', '2026-09-27', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8588, 15, '2026-09-24', 'fertility', 'fertility', NULL, '2026-09-21', '2026-09-27', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8589, 15, '2026-09-25', 'fertility', 'fertility', NULL, '2026-09-21', '2026-09-27', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8590, 15, '2026-09-27', 'fertility', 'fertility', NULL, '2026-09-21', '2026-09-27', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8591, 15, '2026-10-22', 'fertility', 'fertility', NULL, '2026-10-22', '2026-10-28', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8592, 15, '2026-10-23', 'fertility', 'fertility', NULL, '2026-10-22', '2026-10-28', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8593, 15, '2026-10-24', 'fertility', 'fertility', NULL, '2026-10-22', '2026-10-28', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8594, 15, '2026-10-25', 'fertility', 'fertility', NULL, '2026-10-22', '2026-10-28', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8595, 15, '2026-10-26', 'fertility', 'fertility', NULL, '2026-10-22', '2026-10-28', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8596, 15, '2026-10-28', 'fertility', 'fertility', NULL, '2026-10-22', '2026-10-28', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8597, 15, '2026-11-22', 'fertility', 'fertility', NULL, '2026-11-22', '2026-11-28', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8598, 15, '2026-11-23', 'fertility', 'fertility', NULL, '2026-11-22', '2026-11-28', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8599, 15, '2026-11-24', 'fertility', 'fertility', NULL, '2026-11-22', '2026-11-28', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8600, 15, '2026-11-25', 'fertility', 'fertility', NULL, '2026-11-22', '2026-11-28', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8601, 15, '2026-11-26', 'fertility', 'fertility', NULL, '2026-11-22', '2026-11-28', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8602, 15, '2026-11-28', 'fertility', 'fertility', NULL, '2026-11-22', '2026-11-28', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8603, 15, '2026-12-23', 'fertility', 'fertility', NULL, '2026-12-23', '2026-12-29', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8604, 15, '2026-12-24', 'fertility', 'fertility', NULL, '2026-12-23', '2026-12-29', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8605, 15, '2026-12-25', 'fertility', 'fertility', NULL, '2026-12-23', '2026-12-29', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8606, 15, '2026-12-26', 'fertility', 'fertility', NULL, '2026-12-23', '2026-12-29', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8607, 15, '2026-12-27', 'fertility', 'fertility', NULL, '2026-12-23', '2026-12-29', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8608, 15, '2026-12-29', 'fertility', 'fertility', NULL, '2026-12-23', '2026-12-29', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8609, 15, '2027-01-23', 'fertility', 'fertility', NULL, '2027-01-23', '2027-01-29', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8610, 15, '2027-01-24', 'fertility', 'fertility', NULL, '2027-01-23', '2027-01-29', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8611, 15, '2027-01-25', 'fertility', 'fertility', NULL, '2027-01-23', '2027-01-29', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8612, 15, '2027-01-26', 'fertility', 'fertility', NULL, '2027-01-23', '2027-01-29', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8613, 15, '2027-01-27', 'fertility', 'fertility', NULL, '2027-01-23', '2027-01-29', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8614, 15, '2027-01-29', 'fertility', 'fertility', NULL, '2027-01-23', '2027-01-29', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8615, 15, '2027-02-23', 'fertility', 'fertility', NULL, '2027-02-23', '2027-03-01', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8616, 15, '2027-02-24', 'fertility', 'fertility', NULL, '2027-02-23', '2027-03-01', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8617, 15, '2027-02-25', 'fertility', 'fertility', NULL, '2027-02-23', '2027-03-01', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8618, 15, '2027-02-26', 'fertility', 'fertility', NULL, '2027-02-23', '2027-03-01', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8619, 15, '2027-02-27', 'fertility', 'fertility', NULL, '2027-02-23', '2027-03-01', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25'),
(8620, 15, '2027-03-01', 'fertility', 'fertility', NULL, '2027-02-23', '2027-03-01', 'low', 0.400, 'A', '[\"historical_cycle_data\",\"weighted_cycle_statistics\"]', 'fertility', NULL, NULL, 'ecc_prediction_v4_1', '2026-09-24 21:14:25', '2026-09-24 21:14:25');

-- --------------------------------------------------------

--
-- Table structure for table `daily_logs`
--

CREATE TABLE `daily_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `log_date` date NOT NULL,
  `note_encrypted` blob DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `daily_logs`
--

INSERT INTO `daily_logs` (`id`, `user_id`, `log_date`, `note_encrypted`, `created_at`, `updated_at`) VALUES
(1, 2, '2026-09-18', NULL, '2026-09-16 18:36:40', '2026-09-16 18:36:40'),
(2, 2, '2026-09-16', NULL, '2026-09-16 18:36:58', '2026-09-16 19:13:59'),
(3, 2, '2026-09-15', NULL, '2026-09-16 18:40:28', '2026-09-16 18:40:28'),
(6, 2, '2026-09-12', NULL, '2026-09-16 19:14:17', '2026-09-16 19:14:17'),
(7, 13, '2026-09-18', NULL, '2026-09-18 21:53:02', '2026-09-18 21:54:48'),
(10, 15, '2026-09-24', NULL, '2026-09-24 20:48:53', '2026-09-24 21:12:47');

-- --------------------------------------------------------

--
-- Table structure for table `daily_log_items`
--

CREATE TABLE `daily_log_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `daily_log_id` bigint(20) UNSIGNED NOT NULL,
  `category` varchar(64) NOT NULL,
  `item_key` varchar(64) NOT NULL,
  `sensitivity` enum('standard','intimate') NOT NULL DEFAULT 'standard',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `daily_log_items`
--

INSERT INTO `daily_log_items` (`id`, `daily_log_id`, `category`, `item_key`, `sensitivity`, `created_at`) VALUES
(1, 1, 'digestion', 'dig_constipated', 'standard', '2026-09-16 18:36:40'),
(2, 1, 'digestion', 'dig_diarrhea', 'standard', '2026-09-16 18:36:40'),
(3, 1, 'activity', 'act_walking', 'standard', '2026-09-16 18:36:40'),
(6, 3, 'mood', 'mood_calm', 'standard', '2026-09-16 18:40:28'),
(10, 2, 'digestion', 'dig_diarrhea', 'standard', '2026-09-16 19:13:59'),
(11, 2, 'digestion', 'dig_healthy', 'standard', '2026-09-16 19:13:59'),
(12, 2, 'digestion', 'dig_constipated', 'standard', '2026-09-16 19:13:59'),
(15, 7, 'sex', 'sex_unprotected', 'intimate', '2026-09-18 21:54:48'),
(16, 7, 'ovulation_test', 'ov_positive', 'intimate', '2026-09-18 21:54:48'),
(18, 10, 'sex', 'sex_unprotected', 'intimate', '2026-09-24 21:12:47'),
(19, 10, 'mood', 'mood_calm', 'standard', '2026-09-24 21:12:47'),
(20, 10, 'mood', 'mood_anxious', 'standard', '2026-09-24 21:12:47'),
(21, 10, 'mood', 'mood_sad', 'standard', '2026-09-24 21:12:47'),
(22, 10, 'symptoms', 'sym_headache', 'standard', '2026-09-24 21:12:47');

-- --------------------------------------------------------

--
-- Table structure for table `devices`
--

CREATE TABLE `devices` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `device_id` varchar(64) NOT NULL,
  `platform` enum('ios','android','other') NOT NULL DEFAULT 'other',
  `push_token` varchar(512) DEFAULT NULL,
  `app_version` varchar(32) DEFAULT NULL,
  `last_seen_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `devices`
--

INSERT INTO `devices` (`id`, `user_id`, `device_id`, `platform`, `push_token`, `app_version`, `last_seen_at`, `created_at`, `updated_at`) VALUES
(1, 1, 'test-device-1', 'android', NULL, NULL, '2026-09-14 20:08:19', '2026-09-14 20:08:19', '2026-09-14 20:08:19'),
(2, 2, '1dfdd621-912a-44b1-a29f-084e2c9b680c', 'android', NULL, '1.0.0', '2026-09-17 19:17:28', '2026-09-14 20:08:27', '2026-09-17 19:17:28'),
(3, 3, 'debug-me-1', 'android', NULL, NULL, '2026-09-14 20:13:09', '2026-09-14 20:13:09', '2026-09-14 20:13:09'),
(4, 4, 'debug-me-2', 'android', NULL, NULL, '2026-09-14 20:14:35', '2026-09-14 20:14:35', '2026-09-14 20:14:35'),
(5, 5, 'test-local', 'ios', NULL, '1.0.0', '2026-09-16 18:29:36', '2026-09-16 18:29:36', '2026-09-16 18:29:36'),
(6, 6, 'a2666cf1-4c87-4ed3-a10e-e1acec2ff647', 'android', NULL, '1.0.0', '2026-09-17 20:11:05', '2026-09-17 19:37:59', '2026-09-17 20:11:05'),
(9, 8, '76e4b2fd-7101-48d5-a399-780d01b133e9', 'android', NULL, '1.0.0', '2026-09-17 20:13:51', '2026-09-17 20:13:46', '2026-09-17 20:13:51'),
(10, 10, '763aefaf-831e-4d33-928a-5cd9061aca8c', 'android', NULL, '1.0.0', '2026-09-17 20:30:05', '2026-09-17 20:16:19', '2026-09-17 20:30:05'),
(12, 13, '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', 'android', NULL, '1.0.0', '2026-09-24 19:06:50', '2026-09-17 20:31:40', '2026-09-24 19:06:50'),
(14, 14, '222b8a01-fb25-4da2-89d2-022061615f2c', 'android', NULL, '1.0.0', '2026-09-24 20:25:29', '2026-09-24 19:07:00', '2026-09-24 20:25:29'),
(15, 15, 'd1461f63-b9ec-4823-a210-b9a71a105100', 'android', NULL, '1.0.0', '2026-09-24 21:14:34', '2026-09-24 20:25:55', '2026-09-24 21:14:34');

-- --------------------------------------------------------

--
-- Table structure for table `onboarding_answers`
--

CREATE TABLE `onboarding_answers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `flow_key` varchar(64) NOT NULL,
  `step_id` varchar(64) NOT NULL,
  `answer_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`answer_values`)),
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `onboarding_answers`
--

INSERT INTO `onboarding_answers` (`id`, `user_id`, `flow_key`, `step_id`, `answer_values`, `created_at`, `updated_at`) VALUES
(1, 2, 'track_cycle', 'track_cycle_feeling', '[\"worried\"]', '2026-09-14 22:07:40', '2026-09-16 19:10:05'),
(2, 2, 'track_cycle', 'track_cycle_goals', '[\"goal_sleep\"]', '2026-09-14 22:07:40', '2026-09-16 19:10:05'),
(9, 2, 'get_pregnant', 'gp_timeline', '[\"asap\"]', '2026-09-16 19:01:18', '2026-09-16 19:06:09'),
(10, 2, 'get_pregnant', 'gp_trying_duration', '[\"just_started\"]', '2026-09-16 19:01:18', '2026-09-16 19:06:09'),
(11, 2, 'get_pregnant', 'gp_vitamins', '[\"prenatal\"]', '2026-09-16 19:01:18', '2026-09-16 19:06:09'),
(12, 2, 'get_pregnant', 'gp_checkup', '[\"waiting\"]', '2026-09-16 19:01:18', '2026-09-16 19:06:09'),
(13, 2, 'get_pregnant', 'gp_partner', '[\"didnt_know\"]', '2026-09-16 19:01:18', '2026-09-16 19:06:09'),
(14, 2, 'get_pregnant', 'gp_diet', '[\"yes\"]', '2026-09-16 19:01:18', '2026-09-16 19:06:09'),
(15, 2, 'get_pregnant', 'gp_sex_questions', '[\"best_position\"]', '2026-09-16 19:01:18', '2026-09-16 19:06:09'),
(27, 8, 'normal', 'feeling', '[\"excited\"]', '2026-09-17 20:15:05', '2026-09-17 20:15:05'),
(28, 8, 'normal', 'pregnancy_timeline', '[\"asap\"]', '2026-09-17 20:15:05', '2026-09-17 20:15:05'),
(29, 8, 'normal', 'trying_duration', '[\"just_started\"]', '2026-09-17 20:15:05', '2026-09-17 20:15:05'),
(30, 8, 'normal', 'fertile_days', '[\"yes\"]', '2026-09-17 20:15:05', '2026-09-17 20:15:05'),
(31, 8, 'normal', 'regular_periods', '[\"yes\"]', '2026-09-17 20:15:05', '2026-09-17 20:15:05'),
(32, 8, 'normal', 'first_time_conceiving', '[\"children\"]', '2026-09-17 20:15:05', '2026-09-17 20:15:05'),
(33, 8, 'normal', 'birth_control', '[\"currently_using\"]', '2026-09-17 20:15:05', '2026-09-17 20:15:05'),
(34, 8, 'normal', 'health_conditions', '[\"pcos\"]', '2026-09-17 20:15:05', '2026-09-17 20:15:05'),
(35, 8, 'normal', 'discharge', '[\"yes\"]', '2026-09-17 20:15:05', '2026-09-17 20:15:05'),
(36, 8, 'normal', 'healthcare_recommendation', '[\"yes\"]', '2026-09-17 20:15:05', '2026-09-17 20:15:05'),
(37, 8, 'normal', 'prenatal_vitamins', '[\"multivitamin\"]', '2026-09-17 20:15:05', '2026-09-17 20:15:05'),
(38, 8, 'normal', 'pre_pregnancy_checkup', '[\"waiting\"]', '2026-09-17 20:15:05', '2026-09-17 20:15:05'),
(39, 8, 'normal', 'partner_preparation', '[\"didnt_know\"]', '2026-09-17 20:15:05', '2026-09-17 20:15:05'),
(40, 8, 'normal', 'healthy_diet', '[\"not_really\"]', '2026-09-17 20:15:05', '2026-09-17 20:15:05'),
(41, 8, 'normal', 'conception_sex', '[\"best_position\"]', '2026-09-17 20:15:05', '2026-09-17 20:15:05'),
(42, 10, 'partner', 'partner_goals', '[\"plan_partner_cycle\"]', '2026-09-17 20:17:26', '2026-09-17 20:17:26'),
(43, 10, 'partner', 'partner_symptoms', '[\"cramps_backache\",\"headache\"]', '2026-09-17 20:17:26', '2026-09-17 20:17:26'),
(44, 10, 'partner', 'fertility_knowledge', '[\"yes\"]', '2026-09-17 20:17:26', '2026-09-17 20:17:26'),
(45, 10, 'partner', 'sex_life_goals', '[\"new_positions\"]', '2026-09-17 20:17:26', '2026-09-17 20:17:26'),
(46, 10, 'partner', 'support_style', '[\"practical_help\"]', '2026-09-17 20:17:26', '2026-09-17 20:17:26'),
(47, 13, 'partner', 'partner_goals', '[\"plan_partner_cycle\"]', '2026-09-17 20:44:27', '2026-09-17 20:44:27'),
(48, 13, 'partner', 'partner_symptoms', '[\"cramps_backache\"]', '2026-09-17 20:44:27', '2026-09-17 20:44:27'),
(49, 13, 'partner', 'fertility_knowledge', '[\"yes\"]', '2026-09-17 20:44:27', '2026-09-17 20:44:27'),
(50, 13, 'partner', 'sex_life_goals', '[\"new_positions\"]', '2026-09-17 20:44:27', '2026-09-17 20:44:27'),
(51, 13, 'partner', 'support_style', '[\"practical_help\"]', '2026-09-17 20:44:27', '2026-09-17 20:44:27'),
(52, 13, 'normal', 'feeling', '[\"excited\"]', '2026-09-18 20:09:58', '2026-09-18 20:09:58'),
(53, 13, 'normal', 'pregnancy_timeline', '[\"asap\"]', '2026-09-18 20:09:58', '2026-09-18 20:09:58'),
(54, 13, 'normal', 'trying_duration', '[\"just_started\"]', '2026-09-18 20:09:58', '2026-09-18 20:09:58'),
(55, 13, 'normal', 'fertile_days', '[\"yes\"]', '2026-09-18 20:09:58', '2026-09-18 20:09:58'),
(56, 13, 'normal', 'regular_periods', '[\"yes\"]', '2026-09-18 20:09:58', '2026-09-18 20:09:58'),
(57, 13, 'normal', 'first_time_conceiving', '[\"yes\"]', '2026-09-18 20:09:58', '2026-09-18 20:09:58'),
(58, 13, 'normal', 'birth_control', '[\"currently_using\"]', '2026-09-18 20:09:58', '2026-09-18 20:09:58'),
(59, 13, 'normal', 'health_conditions', '[\"endometriosis\"]', '2026-09-18 20:09:58', '2026-09-18 20:09:58'),
(60, 13, 'normal', 'discharge', '[\"yes\"]', '2026-09-18 20:09:58', '2026-09-18 20:09:58'),
(61, 13, 'normal', 'healthcare_recommendation', '[\"yes\"]', '2026-09-18 20:09:58', '2026-09-18 20:09:58'),
(62, 13, 'normal', 'prenatal_vitamins', '[\"multivitamin\"]', '2026-09-18 20:09:58', '2026-09-18 20:09:58'),
(63, 13, 'normal', 'pre_pregnancy_checkup', '[\"waiting\"]', '2026-09-18 20:09:58', '2026-09-18 20:09:58'),
(64, 13, 'normal', 'partner_preparation', '[\"yes\"]', '2026-09-18 20:09:58', '2026-09-18 20:09:58'),
(65, 13, 'normal', 'healthy_diet', '[\"yes\"]', '2026-09-18 20:09:58', '2026-09-18 20:09:58'),
(66, 13, 'normal', 'conception_sex', '[\"best_position\"]', '2026-09-18 20:09:58', '2026-09-18 20:09:58'),
(67, 14, 'normal', 'feeling', '[\"excited\"]', '2026-09-24 19:15:48', '2026-09-24 19:15:48'),
(68, 14, 'normal', 'pregnancy_timeline', '[\"asap\"]', '2026-09-24 19:15:48', '2026-09-24 19:15:48'),
(69, 14, 'normal', 'trying_duration', '[\"just_started\"]', '2026-09-24 19:15:48', '2026-09-24 19:15:48'),
(70, 14, 'normal', 'fertile_days', '[\"yes\"]', '2026-09-24 19:15:48', '2026-09-24 19:15:48'),
(71, 14, 'normal', 'regular_periods', '[\"yes\"]', '2026-09-24 19:15:48', '2026-09-24 19:15:48'),
(72, 14, 'normal', 'first_time_conceiving', '[\"children\"]', '2026-09-24 19:15:48', '2026-09-24 19:15:48'),
(73, 14, 'normal', 'birth_control', '[\"currently_using\"]', '2026-09-24 19:15:48', '2026-09-24 19:15:48'),
(74, 14, 'normal', 'health_conditions', '[\"pcos\"]', '2026-09-24 19:15:48', '2026-09-24 19:15:48'),
(75, 14, 'normal', 'discharge', '[\"yes\"]', '2026-09-24 19:15:48', '2026-09-24 19:15:48'),
(76, 14, 'normal', 'healthcare_recommendation', '[\"yes\"]', '2026-09-24 19:15:48', '2026-09-24 19:15:48'),
(77, 14, 'normal', 'prenatal_vitamins', '[\"multivitamin\"]', '2026-09-24 19:15:48', '2026-09-24 19:15:48'),
(78, 14, 'normal', 'pre_pregnancy_checkup', '[\"waiting\"]', '2026-09-24 19:15:48', '2026-09-24 19:15:48'),
(79, 14, 'normal', 'partner_preparation', '[\"yes\"]', '2026-09-24 19:15:48', '2026-09-24 19:15:48'),
(80, 14, 'normal', 'healthy_diet', '[\"yes\"]', '2026-09-24 19:15:48', '2026-09-24 19:15:48'),
(81, 14, 'normal', 'conception_sex', '[\"best_position\"]', '2026-09-24 19:15:48', '2026-09-24 19:15:48'),
(82, 15, 'normal', 'feeling', '[\"excited\"]', '2026-09-24 20:31:51', '2026-09-24 20:31:51'),
(83, 15, 'normal', 'pregnancy_timeline', '[\"asap\"]', '2026-09-24 20:31:51', '2026-09-24 20:31:51'),
(84, 15, 'normal', 'first_time_conceiving', '[\"children\"]', '2026-09-24 20:31:51', '2026-09-24 20:31:51'),
(85, 15, 'normal', 'birth_control', '[\"currently_using\"]', '2026-09-24 20:31:51', '2026-09-24 20:31:51'),
(86, 15, 'normal', 'health_conditions', '[\"pcos\"]', '2026-09-24 20:31:51', '2026-09-24 20:31:51'),
(87, 15, 'normal', 'discharge', '[\"yes\"]', '2026-09-24 20:31:51', '2026-09-24 20:31:51'),
(88, 15, 'normal', 'healthcare_recommendation', '[\"yes\"]', '2026-09-24 20:31:51', '2026-09-24 20:31:51'),
(89, 15, 'normal', 'prenatal_vitamins', '[\"multivitamin\"]', '2026-09-24 20:31:51', '2026-09-24 20:31:51'),
(90, 15, 'normal', 'pre_pregnancy_checkup', '[\"waiting\"]', '2026-09-24 20:31:51', '2026-09-24 20:31:51'),
(91, 15, 'normal', 'partner_preparation', '[\"didnt_know\"]', '2026-09-24 20:31:51', '2026-09-24 20:31:51'),
(92, 15, 'normal', 'healthy_diet', '[\"yes\"]', '2026-09-24 20:31:51', '2026-09-24 20:31:51'),
(93, 15, 'normal', 'conception_sex', '[\"best_position\"]', '2026-09-24 20:31:51', '2026-09-24 20:31:51'),
(94, 15, 'track_cycle', 'track_cycle_feeling', '[\"calm\"]', '2026-09-24 21:14:07', '2026-09-24 21:14:07'),
(95, 15, 'track_cycle', 'track_cycle_goals', '[\"goal_mood\"]', '2026-09-24 21:14:07', '2026-09-24 21:14:07');

-- --------------------------------------------------------

--
-- Table structure for table `partner_links`
--

CREATE TABLE `partner_links` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` char(6) NOT NULL,
  `owner_user_id` bigint(20) UNSIGNED NOT NULL,
  `partner_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `status` enum('pending','active','revoked') NOT NULL DEFAULT 'pending',
  `share_scope` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`share_scope`)),
  `owner_consented_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `linked_at` datetime DEFAULT NULL,
  `revoked_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `partner_links`
--

INSERT INTO `partner_links` (`id`, `code`, `owner_user_id`, `partner_user_id`, `status`, `share_scope`, `owner_consented_at`, `created_at`, `linked_at`, `revoked_at`) VALUES
(1, 'P4UMJK', 8, 10, 'active', '[\"cycle_phase\",\"predicted_period\",\"predicted_fertile\",\"predicted_ovulation\"]', '2026-09-17 20:15:18', '2026-09-17 20:15:18', '2026-09-17 20:17:05', NULL),
(2, 'P4UMJK', 8, NULL, 'pending', '[\"cycle_phase\",\"predicted_period\",\"predicted_fertile\",\"predicted_ovulation\"]', '2026-09-17 20:15:18', '2026-09-17 20:44:09', NULL, NULL),
(3, 'P4UMJK', 8, 13, 'active', '[\"cycle_phase\",\"predicted_period\",\"predicted_fertile\",\"predicted_ovulation\"]', '2026-09-17 20:15:18', '2026-09-17 20:44:09', '2026-09-17 20:44:09', NULL),
(4, 'M8UFTG', 14, NULL, 'pending', '[\"cycle_phase\",\"predicted_period\",\"predicted_fertile\",\"predicted_ovulation\"]', '2026-09-24 19:16:01', '2026-09-24 19:16:01', NULL, NULL),
(5, 'E757H4', 15, NULL, 'pending', '[\"cycle_phase\",\"predicted_period\",\"predicted_fertile\",\"predicted_ovulation\"]', '2026-09-24 20:32:12', '2026-09-24 20:32:12', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `period_days`
--

CREATE TABLE `period_days` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `log_date` date NOT NULL,
  `flow_intensity` enum('none','spotting','light','medium','heavy') DEFAULT NULL,
  `is_predicted` tinyint(1) NOT NULL DEFAULT 0,
  `cycle_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `period_days`
--

INSERT INTO `period_days` (`id`, `user_id`, `log_date`, `flow_intensity`, `is_predicted`, `cycle_id`, `created_at`, `updated_at`) VALUES
(316, 2, '2026-01-02', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(317, 2, '2026-01-03', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(318, 2, '2026-01-04', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(319, 2, '2026-01-06', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(320, 2, '2026-02-03', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(321, 2, '2026-02-05', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(322, 2, '2026-07-24', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(323, 2, '2026-07-25', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(324, 2, '2026-07-29', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(325, 2, '2026-07-30', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(326, 2, '2026-07-31', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(327, 2, '2026-08-13', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(328, 2, '2026-08-14', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(329, 2, '2026-08-15', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(330, 2, '2026-08-16', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(331, 2, '2026-08-26', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(332, 2, '2026-08-27', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(333, 2, '2026-08-28', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(334, 2, '2026-08-29', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(335, 2, '2026-08-30', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(336, 2, '2026-09-04', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(337, 2, '2026-09-05', NULL, 0, NULL, '2026-09-16 18:44:50', '2026-09-16 18:44:50'),
(364, 8, '2026-08-11', NULL, 0, NULL, '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(365, 8, '2026-08-12', NULL, 0, NULL, '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(366, 8, '2026-08-13', NULL, 0, NULL, '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(367, 8, '2026-08-14', NULL, 0, NULL, '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(368, 8, '2026-08-15', NULL, 0, NULL, '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(369, 8, '2026-08-27', NULL, 0, NULL, '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(370, 8, '2026-08-28', NULL, 0, NULL, '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(371, 8, '2026-08-29', NULL, 0, NULL, '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(372, 8, '2026-09-09', NULL, 0, NULL, '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(373, 8, '2026-09-10', NULL, 0, NULL, '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(374, 8, '2026-09-11', NULL, 0, NULL, '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(375, 8, '2026-09-12', NULL, 0, NULL, '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(376, 8, '2026-09-13', NULL, 0, NULL, '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(618, 13, '2026-07-15', NULL, 0, NULL, '2026-09-18 21:57:43', '2026-09-18 21:57:43'),
(619, 13, '2026-07-16', NULL, 0, NULL, '2026-09-18 21:57:43', '2026-09-18 21:57:43'),
(620, 13, '2026-07-17', NULL, 0, NULL, '2026-09-18 21:57:43', '2026-09-18 21:57:43'),
(621, 13, '2026-07-18', NULL, 0, NULL, '2026-09-18 21:57:43', '2026-09-18 21:57:43'),
(622, 13, '2026-07-19', NULL, 0, NULL, '2026-09-18 21:57:43', '2026-09-18 21:57:43'),
(623, 13, '2026-08-19', NULL, 0, NULL, '2026-09-18 21:57:43', '2026-09-18 21:57:43'),
(624, 13, '2026-08-20', NULL, 0, NULL, '2026-09-18 21:57:43', '2026-09-18 21:57:43'),
(625, 13, '2026-08-21', NULL, 0, NULL, '2026-09-18 21:57:43', '2026-09-18 21:57:43'),
(626, 13, '2026-08-22', NULL, 0, NULL, '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(627, 13, '2026-08-23', NULL, 0, NULL, '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(628, 13, '2026-09-09', NULL, 0, NULL, '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(629, 13, '2026-09-10', NULL, 0, NULL, '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(630, 13, '2026-09-11', NULL, 0, NULL, '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(631, 13, '2026-09-12', NULL, 0, NULL, '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(632, 13, '2026-09-13', NULL, 0, NULL, '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(633, 13, '2026-09-16', NULL, 0, NULL, '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(634, 13, '2026-09-17', NULL, 0, NULL, '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(635, 13, '2026-09-18', NULL, 0, NULL, '2026-09-18 21:57:44', '2026-09-18 21:57:44'),
(657, 14, '2026-09-09', NULL, 0, NULL, '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(658, 14, '2026-09-10', NULL, 0, NULL, '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(659, 14, '2026-09-11', NULL, 0, NULL, '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(660, 14, '2026-09-12', NULL, 0, NULL, '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(661, 14, '2026-09-13', NULL, 0, NULL, '2026-09-24 19:16:39', '2026-09-24 19:16:39'),
(1315, 15, '2026-08-09', NULL, 0, NULL, '2026-09-24 21:13:45', '2026-09-24 21:13:45'),
(1316, 15, '2026-08-10', NULL, 0, NULL, '2026-09-24 21:13:45', '2026-09-24 21:13:45'),
(1317, 15, '2026-08-11', NULL, 0, NULL, '2026-09-24 21:13:45', '2026-09-24 21:13:45'),
(1318, 15, '2026-08-12', NULL, 0, NULL, '2026-09-24 21:13:45', '2026-09-24 21:13:45'),
(1319, 15, '2026-08-13', NULL, 0, NULL, '2026-09-24 21:13:45', '2026-09-24 21:13:45'),
(1320, 15, '2026-08-14', NULL, 0, NULL, '2026-09-24 21:13:45', '2026-09-24 21:13:45'),
(1321, 15, '2026-08-15', NULL, 0, NULL, '2026-09-24 21:13:45', '2026-09-24 21:13:45'),
(1322, 15, '2026-08-16', NULL, 0, NULL, '2026-09-24 21:13:45', '2026-09-24 21:13:45'),
(1323, 15, '2026-09-09', NULL, 0, NULL, '2026-09-24 21:13:45', '2026-09-24 21:13:45'),
(1324, 15, '2026-09-10', NULL, 0, NULL, '2026-09-24 21:13:45', '2026-09-24 21:13:45'),
(1325, 15, '2026-09-11', NULL, 0, NULL, '2026-09-24 21:13:45', '2026-09-24 21:13:45'),
(1326, 15, '2026-09-12', NULL, 0, NULL, '2026-09-24 21:13:45', '2026-09-24 21:13:45'),
(1327, 15, '2026-09-13', NULL, 0, NULL, '2026-09-24 21:13:45', '2026-09-24 21:13:45');

-- --------------------------------------------------------

--
-- Table structure for table `posts`
--

CREATE TABLE `posts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `content` text NOT NULL,
  `image_url` varchar(512) DEFAULT NULL,
  `likes_count` int(11) NOT NULL DEFAULT 0,
  `comments_count` int(11) NOT NULL DEFAULT 0,
  `is_hidden` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `posts`
--

INSERT INTO `posts` (`id`, `user_id`, `content`, `image_url`, `likes_count`, `comments_count`, `is_hidden`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 13, 'hello testing profile', 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=800&auto=format&fit=crop', 1, 1, 0, '2026-09-18 21:13:58', '2026-09-18 21:14:12', NULL),
(2, 13, 'This is the post', '/uploads/posts/post_1789751599717_nxdrvys4.jpg', 0, 0, 0, '2026-09-18 22:13:19', '2026-09-18 22:13:19', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `post_comments`
--

CREATE TABLE `post_comments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `post_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `body` text NOT NULL,
  `likes_count` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `post_comments`
--

INSERT INTO `post_comments` (`id`, `post_id`, `user_id`, `body`, `likes_count`, `created_at`, `deleted_at`) VALUES
(1, 1, 13, 'zohaib here', 1, '2026-09-18 21:14:12', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `post_likes`
--

CREATE TABLE `post_likes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `post_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `post_likes`
--

INSERT INTO `post_likes` (`id`, `post_id`, `user_id`, `created_at`) VALUES
(1, 1, 13, '2026-09-18 21:14:05');

-- --------------------------------------------------------

--
-- Table structure for table `prediction_validation_log`
--

CREATE TABLE `prediction_validation_log` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `event_type` enum('period_start') NOT NULL DEFAULT 'period_start',
  `actual_date` date NOT NULL,
  `predicted_date` date DEFAULT NULL,
  `delta_days` int(11) DEFAULT NULL COMMENT 'actual - predicted (days); NULL if no prediction',
  `algorithm_version` varchar(32) DEFAULT NULL,
  `meta_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`meta_json`)),
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `prediction_validation_log`
--

INSERT INTO `prediction_validation_log` (`id`, `user_id`, `event_type`, `actual_date`, `predicted_date`, `delta_days`, `algorithm_version`, `meta_json`, `created_at`) VALUES
(1, 8, 'period_start', '2026-08-11', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-17 20:14:31'),
(2, 8, 'period_start', '2026-08-27', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-17 20:14:31'),
(3, 8, 'period_start', '2026-09-09', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-17 20:14:31'),
(4, 13, 'period_start', '2026-07-15', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-18 20:09:16'),
(5, 13, 'period_start', '2026-08-19', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-18 20:09:16'),
(6, 13, 'period_start', '2026-09-09', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-18 20:09:16'),
(7, 13, 'period_start', '2026-09-18', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-18 20:10:28'),
(8, 13, 'period_start', '2026-09-17', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-18 20:10:30'),
(9, 13, 'period_start', '2026-09-18', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-18 20:11:01'),
(10, 13, 'period_start', '2026-09-18', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-18 20:26:29'),
(11, 13, 'period_start', '2026-09-17', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-18 21:43:35'),
(12, 13, 'period_start', '2026-09-16', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-18 21:43:39'),
(13, 13, 'period_start', '2026-09-17', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-18 21:43:41'),
(14, 13, 'period_start', '2026-09-18', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-18 21:43:43'),
(15, 13, 'period_start', '2026-09-16', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-18 21:43:48'),
(16, 14, 'period_start', '2026-09-09', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 19:15:17'),
(17, 14, 'period_start', '2026-09-23', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 19:16:35'),
(18, 15, 'period_start', '2026-09-09', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:31:15'),
(19, 15, 'period_start', '2026-08-12', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:46:53'),
(20, 15, 'period_start', '2026-08-04', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:49:17'),
(21, 15, 'period_start', '2026-08-10', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:50:03'),
(22, 15, 'period_start', '2026-08-03', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:50:17'),
(23, 15, 'period_start', '2026-08-04', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:50:21'),
(24, 15, 'period_start', '2026-08-03', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:50:23'),
(25, 15, 'period_start', '2026-08-05', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:50:23'),
(26, 15, 'period_start', '2026-08-04', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:50:24'),
(27, 15, 'period_start', '2026-08-03', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:50:25'),
(28, 15, 'period_start', '2026-08-05', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:50:25'),
(29, 15, 'period_start', '2026-08-04', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:50:26'),
(30, 15, 'period_start', '2026-08-03', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:50:27'),
(31, 15, 'period_start', '2026-08-05', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:50:27'),
(32, 15, 'period_start', '2026-08-04', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:50:28'),
(33, 15, 'period_start', '2026-08-05', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:51:47'),
(34, 15, 'period_start', '2026-08-06', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:51:50'),
(35, 15, 'period_start', '2026-08-07', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:51:53'),
(36, 15, 'period_start', '2026-08-06', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:51:55'),
(37, 15, 'period_start', '2026-08-08', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:51:55'),
(38, 15, 'period_start', '2026-08-09', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 20:52:14'),
(39, 15, 'period_start', '2026-09-17', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 21:12:56'),
(40, 15, 'period_start', '2026-09-18', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 21:13:22'),
(41, 15, 'period_start', '2026-09-19', NULL, NULL, 'ecc_prediction_v4_1', '{\"matched_within_days\":null}', '2026-09-24 21:13:27');

-- --------------------------------------------------------

--
-- Table structure for table `refresh_tokens`
--

CREATE TABLE `refresh_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `token_hash` varchar(255) NOT NULL,
  `device_id` varchar(64) DEFAULT NULL,
  `expires_at` datetime NOT NULL,
  `revoked_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `refresh_tokens`
--

INSERT INTO `refresh_tokens` (`id`, `user_id`, `token_hash`, `device_id`, `expires_at`, `revoked_at`, `created_at`) VALUES
(1, 1, 'e70a7ef902cb37c5dc10537a9fa4bb502295768d304e987df078e59089b4a1ab', 'test-device-1', '2026-10-14 20:08:19', NULL, '2026-09-14 20:08:19'),
(2, 2, '6d9727d8ca2c51bdab8daaa4887c5307e3884211f10e48ede8cbcc3a28361837', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '2026-10-14 20:08:27', '2026-09-14 20:08:27', '2026-09-14 20:08:27'),
(3, 2, '6d9727d8ca2c51bdab8daaa4887c5307e3884211f10e48ede8cbcc3a28361837', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '2026-10-14 20:08:27', '2026-09-14 20:08:48', '2026-09-14 20:08:27'),
(4, 2, '048ed850f2df83727e06406e64d08b261abd8dd6d435fb7c1db00a214842f255', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '2026-10-14 20:08:48', '2026-09-14 20:09:08', '2026-09-14 20:08:48'),
(5, 2, '8d16d51ce179cbcdd5c23b91682a3868df3a02152f6b3e5568e182ee87c24687', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '2026-10-14 20:09:08', '2026-09-14 20:09:44', '2026-09-14 20:09:08'),
(6, 2, '7402fa85b1521892669740611bedf145b3d63ff25c8a9d1acec3a0969fb323b6', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '2026-10-14 20:09:44', '2026-09-14 20:12:28', '2026-09-14 20:09:44'),
(7, 2, '70d3908cd217010243f050579044ccc5bc03cc70090aee6ecfa547efd9078b27', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '2026-10-14 20:12:28', '2026-09-14 20:46:40', '2026-09-14 20:12:28'),
(8, 3, '8a8598720fcabda1c85cec0d249190639421826e8191392add2d5fec289d48e1', 'debug-me-1', '2026-10-14 20:13:09', NULL, '2026-09-14 20:13:09'),
(9, 4, '8af9934b411761074160ce4905638a829b2d0e36af55c13ecbc6d22713840a30', 'debug-me-2', '2026-10-14 20:14:35', NULL, '2026-09-14 20:14:35'),
(10, 2, '25e03595c2d0709909af137fc6a41cd770fdc2dcb52b906a07cb4098077c92bf', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '2026-10-14 20:46:40', '2026-09-14 21:02:32', '2026-09-14 20:46:40'),
(11, 2, '9e9bc39085e7c2acdf03b88e32e54d7355b672141d849236a5a472193207420d', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '2026-10-14 21:02:32', NULL, '2026-09-14 21:02:32'),
(12, 2, '4ec44539dbacf28abf96270cac4e786be6677c1225c9526ac264434dad250c5f', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 21:28:18'),
(13, 2, 'adfe602a04becfbc72c980a716149780bbc963e3f83e1e3a93ddc9fdce85bf83', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 21:30:26'),
(14, 2, 'adfe602a04becfbc72c980a716149780bbc963e3f83e1e3a93ddc9fdce85bf83', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 21:30:26'),
(15, 2, '7681dc95128860e56f4533afbb73d8a9ed6bd9dbd17dcecac0e2f777e58f6eb0', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 21:52:56'),
(16, 2, '7681dc95128860e56f4533afbb73d8a9ed6bd9dbd17dcecac0e2f777e58f6eb0', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 21:52:56'),
(17, 2, 'f0e949c2513e01792c639d92bcf719e45bbf40f73f0fffa1740ac0da22590038', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 21:53:16'),
(18, 2, 'f0e949c2513e01792c639d92bcf719e45bbf40f73f0fffa1740ac0da22590038', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 21:53:16'),
(19, 2, '0efc4b51d730b085bff38aa0e5944a5e9ed023b2766155afd3ef461a35da63fa', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 22:02:01'),
(20, 2, '0efc4b51d730b085bff38aa0e5944a5e9ed023b2766155afd3ef461a35da63fa', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 22:02:01'),
(21, 2, '7bd514003c11be538c41a37b3241d3114b8a65aa140970b7305105ca99ffed1a', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 22:02:44'),
(22, 2, '7bd514003c11be538c41a37b3241d3114b8a65aa140970b7305105ca99ffed1a', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 22:02:44'),
(23, 2, 'bb70a6613d5b62adf01fbba62ccc579d4a2f5074a681d7edf5b46cc5efe5ddcb', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 22:03:03'),
(24, 2, 'bb70a6613d5b62adf01fbba62ccc579d4a2f5074a681d7edf5b46cc5efe5ddcb', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 22:03:03'),
(25, 2, '3a2ff1f5f2bc887eb0a486195435425a0f40692ca479d506570bede982570770', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 22:04:19'),
(26, 2, '3a2ff1f5f2bc887eb0a486195435425a0f40692ca479d506570bede982570770', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 22:04:19'),
(27, 2, 'c235529c3b911e1c94917ede422a6fcdeb722d639db6776d9157061f4c80dae7', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 22:06:49'),
(28, 2, 'c235529c3b911e1c94917ede422a6fcdeb722d639db6776d9157061f4c80dae7', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 22:06:49'),
(29, 2, 'e6d84250af43074a1d98fd0388cae5c79651418074815148d8811be1cc83bc76', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 22:10:45'),
(30, 2, 'e6d84250af43074a1d98fd0388cae5c79651418074815148d8811be1cc83bc76', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 22:10:45'),
(31, 2, '4f26e0b39d4f6aaea23ca580153bf44da28a582350ea12edfee7b683df832f30', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 22:11:44'),
(32, 2, '4f26e0b39d4f6aaea23ca580153bf44da28a582350ea12edfee7b683df832f30', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 22:11:44'),
(33, 2, '6a5f8e1dce62581d60453efdc02af1d96c3ff945787f6d6f0b0786392c6445c6', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 22:15:45'),
(34, 2, '6a5f8e1dce62581d60453efdc02af1d96c3ff945787f6d6f0b0786392c6445c6', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 22:15:45'),
(35, 2, '4a0403d195f905c7aeba189034f4f14e94b3b4a0e7043ec6699a3aaf8250fe0e', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 23:32:21'),
(36, 2, '4a0403d195f905c7aeba189034f4f14e94b3b4a0e7043ec6699a3aaf8250fe0e', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-14 23:32:21'),
(37, 5, '9279171996e4bbca3e2fde900349ac072b5aea26345ff13fb1033ee6d0a72100', 'test-local', '0000-00-00 00:00:00', NULL, '2026-09-16 18:29:36'),
(38, 2, 'e10cc9ca0a00ec0591c3b3a61186476bc8fc707b74905e087c77ff5dbbaba0cb', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 18:34:36'),
(39, 2, 'e10cc9ca0a00ec0591c3b3a61186476bc8fc707b74905e087c77ff5dbbaba0cb', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 18:34:36'),
(40, 2, '5e40ebf375608f915d2d834754432be94ef80d7da1bca844dda4622b56e8970a', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 18:36:14'),
(41, 2, '5e40ebf375608f915d2d834754432be94ef80d7da1bca844dda4622b56e8970a', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 18:36:14'),
(42, 2, 'a32418c61ce42855cb7d3ea728d6208d640a97018184ead8956089f064a27261', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 18:40:15'),
(43, 2, 'a32418c61ce42855cb7d3ea728d6208d640a97018184ead8956089f064a27261', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 18:40:15'),
(44, 2, '20db7746f57a679b705f6c68ae0a94d85eb2ad0350289c0dee228d7271a9badc', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 18:41:17'),
(45, 2, '20db7746f57a679b705f6c68ae0a94d85eb2ad0350289c0dee228d7271a9badc', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 18:41:17'),
(46, 2, 'da1e6ebcb98967c90a6a99d70511ab893cd3e27b5dca579d855a8d36d8ddaca7', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 18:49:36'),
(47, 2, 'da1e6ebcb98967c90a6a99d70511ab893cd3e27b5dca579d855a8d36d8ddaca7', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 18:49:36'),
(48, 2, '548cedb615858a1c28bb004e58d6a0ce0b4ea20d96ae870848f945722179eefb', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 18:56:54'),
(49, 2, '548cedb615858a1c28bb004e58d6a0ce0b4ea20d96ae870848f945722179eefb', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 18:56:54'),
(50, 2, '1ce8a71dde0f2688a3f78e92317c5f0aa98a4adc1733f0d366c2dbeb4b78c23f', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 18:57:02'),
(51, 2, '1ce8a71dde0f2688a3f78e92317c5f0aa98a4adc1733f0d366c2dbeb4b78c23f', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 18:57:02'),
(52, 2, '53e0532fe1a48516ad0e9ea02aad9a44bdf94b43fea0075092986a7dc663b226', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 18:57:36'),
(53, 2, '53e0532fe1a48516ad0e9ea02aad9a44bdf94b43fea0075092986a7dc663b226', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 18:57:36'),
(54, 2, '7a887457e49f9f259dda1dcc628247d74d91b975794afda4c230c191902a4fd1', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 19:00:48'),
(55, 2, '7a887457e49f9f259dda1dcc628247d74d91b975794afda4c230c191902a4fd1', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 19:00:48'),
(56, 2, '74d19bb27ba05f023673bbb28d527aba94057c14abd25b0028a5a9ad21e502d2', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 19:02:56'),
(57, 2, '74d19bb27ba05f023673bbb28d527aba94057c14abd25b0028a5a9ad21e502d2', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 19:02:56'),
(58, 2, 'fcb173b4631dd78028e78341d5d8be4d1c057cc21c19f03053d9af931667184f', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 19:05:42'),
(59, 2, 'fcb173b4631dd78028e78341d5d8be4d1c057cc21c19f03053d9af931667184f', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 19:05:42'),
(60, 2, 'd8e844cf40032c56e45ad0f2b8da42a0788dbf196b521865d803e61b079d49f7', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 19:09:48'),
(61, 2, 'd8e844cf40032c56e45ad0f2b8da42a0788dbf196b521865d803e61b079d49f7', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 19:09:48'),
(62, 2, '9a3ef4d60ed0d0c6cb81f8c0a5a7fa8ad898eecddf616508bff083b06bc8c558', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 19:10:55'),
(63, 2, '9a3ef4d60ed0d0c6cb81f8c0a5a7fa8ad898eecddf616508bff083b06bc8c558', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 19:10:55'),
(64, 2, '961cf1fc9944a4458e87792bf494c48dcfeca4aaa2155cff8c9a378a8481976a', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 19:11:47'),
(65, 2, '961cf1fc9944a4458e87792bf494c48dcfeca4aaa2155cff8c9a378a8481976a', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-16 19:11:47'),
(66, 2, 'd9e374200c1e174f4a900fe4ebcaf436e1b7f7d12dba2baef4b3aa8d9f041af7', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-17 19:17:28'),
(67, 2, 'd9e374200c1e174f4a900fe4ebcaf436e1b7f7d12dba2baef4b3aa8d9f041af7', '1dfdd621-912a-44b1-a29f-084e2c9b680c', '0000-00-00 00:00:00', NULL, '2026-09-17 19:17:28'),
(68, 6, 'cd16b4029e455982e422a2d2132c6105208e0b8225c631719d87ab58af43c8b1', 'a2666cf1-4c87-4ed3-a10e-e1acec2ff647', '0000-00-00 00:00:00', NULL, '2026-09-17 19:38:00'),
(69, 6, '2c32a8449e160802e4d5a357c3ff83d57ebd0caeff22379a25ad48812e5a8766', 'a2666cf1-4c87-4ed3-a10e-e1acec2ff647', '0000-00-00 00:00:00', NULL, '2026-09-17 20:02:21'),
(70, 6, '458dace144f3e2d0dea84ce55ea042e1712ba91b40117f4b093c6ee706147b7e', 'a2666cf1-4c87-4ed3-a10e-e1acec2ff647', '0000-00-00 00:00:00', NULL, '2026-09-17 20:04:56'),
(71, 6, '458dace144f3e2d0dea84ce55ea042e1712ba91b40117f4b093c6ee706147b7e', 'a2666cf1-4c87-4ed3-a10e-e1acec2ff647', '0000-00-00 00:00:00', NULL, '2026-09-17 20:04:56'),
(72, 6, '5bce54ddd5ff544f7498007c746678eef54e09b48c7a8ba87c6b7c3cb065915c', 'a2666cf1-4c87-4ed3-a10e-e1acec2ff647', '0000-00-00 00:00:00', NULL, '2026-09-17 20:08:46'),
(73, 6, '5bce54ddd5ff544f7498007c746678eef54e09b48c7a8ba87c6b7c3cb065915c', 'a2666cf1-4c87-4ed3-a10e-e1acec2ff647', '0000-00-00 00:00:00', NULL, '2026-09-17 20:08:46'),
(74, 6, '4bed22147b0e04cb9e35eaa08cbbde212e347ae2f3b342ca31852beb533c586e', 'a2666cf1-4c87-4ed3-a10e-e1acec2ff647', '0000-00-00 00:00:00', NULL, '2026-09-17 20:11:05'),
(75, 6, '4bed22147b0e04cb9e35eaa08cbbde212e347ae2f3b342ca31852beb533c586e', 'a2666cf1-4c87-4ed3-a10e-e1acec2ff647', '0000-00-00 00:00:00', NULL, '2026-09-17 20:11:05'),
(76, 8, '103f82f696f329d36ebd4d780602a89e0130068cb97bd1429ef517268ac95fb0', '76e4b2fd-7101-48d5-a399-780d01b133e9', '0000-00-00 00:00:00', NULL, '2026-09-17 20:13:46'),
(77, 8, '11613964689101b8ea3e8f79b50858f519accaeaf78dc56a30a4f35020fc865d', '76e4b2fd-7101-48d5-a399-780d01b133e9', '0000-00-00 00:00:00', NULL, '2026-09-17 20:13:51'),
(78, 10, '43a56f97d8f408ed3a64331010e988efc1e36d6616ddc36b948806a3fab62971', '763aefaf-831e-4d33-928a-5cd9061aca8c', '0000-00-00 00:00:00', NULL, '2026-09-17 20:16:19'),
(79, 10, '0efadebbebc853ade3773e9a1b8179ab11b9b11b658127dfa0e561b761a13226', '763aefaf-831e-4d33-928a-5cd9061aca8c', '0000-00-00 00:00:00', NULL, '2026-09-17 20:16:25'),
(80, 10, 'd510f6d9b0ae21d7c8e8a3aa585fa36986e6c91dbe5754e7907fd6a254758a29', '763aefaf-831e-4d33-928a-5cd9061aca8c', '0000-00-00 00:00:00', NULL, '2026-09-17 20:17:59'),
(81, 10, 'd510f6d9b0ae21d7c8e8a3aa585fa36986e6c91dbe5754e7907fd6a254758a29', '763aefaf-831e-4d33-928a-5cd9061aca8c', '0000-00-00 00:00:00', NULL, '2026-09-17 20:17:59'),
(82, 10, 'd29fe8237594f18e3062ed91702e11f03183f5c5e54aee322734282e13caf909', '763aefaf-831e-4d33-928a-5cd9061aca8c', '0000-00-00 00:00:00', NULL, '2026-09-17 20:18:53'),
(83, 10, 'd29fe8237594f18e3062ed91702e11f03183f5c5e54aee322734282e13caf909', '763aefaf-831e-4d33-928a-5cd9061aca8c', '0000-00-00 00:00:00', NULL, '2026-09-17 20:18:53'),
(84, 10, '19bb6dd865073a6a11c1622dcf1cdb1e09789a2150b1a0e842d0e8857340de2a', '763aefaf-831e-4d33-928a-5cd9061aca8c', '0000-00-00 00:00:00', NULL, '2026-09-17 20:23:18'),
(85, 10, '19bb6dd865073a6a11c1622dcf1cdb1e09789a2150b1a0e842d0e8857340de2a', '763aefaf-831e-4d33-928a-5cd9061aca8c', '0000-00-00 00:00:00', NULL, '2026-09-17 20:23:18'),
(86, 10, '7fecc66820dfedce17315bf3b5dc6c7b1897b5bfef9c62be1dad91a3cfa355e9', '763aefaf-831e-4d33-928a-5cd9061aca8c', '0000-00-00 00:00:00', NULL, '2026-09-17 20:25:04'),
(87, 10, '7fecc66820dfedce17315bf3b5dc6c7b1897b5bfef9c62be1dad91a3cfa355e9', '763aefaf-831e-4d33-928a-5cd9061aca8c', '0000-00-00 00:00:00', NULL, '2026-09-17 20:25:04'),
(88, 10, '2372bc3b9f83a87e7d7da57410312ccd0dede4cc1f8fd199d09f35de3ea01f78', '763aefaf-831e-4d33-928a-5cd9061aca8c', '0000-00-00 00:00:00', NULL, '2026-09-17 20:26:16'),
(89, 10, '2372bc3b9f83a87e7d7da57410312ccd0dede4cc1f8fd199d09f35de3ea01f78', '763aefaf-831e-4d33-928a-5cd9061aca8c', '0000-00-00 00:00:00', NULL, '2026-09-17 20:26:16'),
(90, 10, 'cda63da96cf8ad76343ab6cf5ebd80f1398ed7b32c3ca3e6e247bb3207e6db58', '763aefaf-831e-4d33-928a-5cd9061aca8c', '0000-00-00 00:00:00', NULL, '2026-09-17 20:28:56'),
(91, 10, 'cda63da96cf8ad76343ab6cf5ebd80f1398ed7b32c3ca3e6e247bb3207e6db58', '763aefaf-831e-4d33-928a-5cd9061aca8c', '0000-00-00 00:00:00', NULL, '2026-09-17 20:28:56'),
(92, 10, 'a3df4ba477a3ba98f32ca99a23be2bf0d47b62e02138a50f56890605cdd87c8d', '763aefaf-831e-4d33-928a-5cd9061aca8c', '0000-00-00 00:00:00', NULL, '2026-09-17 20:30:05'),
(93, 10, 'a3df4ba477a3ba98f32ca99a23be2bf0d47b62e02138a50f56890605cdd87c8d', '763aefaf-831e-4d33-928a-5cd9061aca8c', '0000-00-00 00:00:00', NULL, '2026-09-17 20:30:05'),
(94, 13, '72b394934f356054603375fbca8055c178edb8e4e343a0178be184772fc6d7d2', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-17 20:31:40'),
(95, 13, 'ae56a2ddfd418c29ec81dd8d4bdfb6da74d97ccaced9192654db589a33b111a6', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-17 20:35:58'),
(96, 13, 'f389490b5eb664f0f278e09152dd71642731591683f44bd30dfb544157daa908', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-17 20:38:52'),
(97, 13, 'f389490b5eb664f0f278e09152dd71642731591683f44bd30dfb544157daa908', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-17 20:38:52'),
(98, 13, 'd332a924420d9653f71c675acd2fdb9030f4384a9a33e256eb72237abb1fbb56', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-17 20:39:57'),
(99, 13, 'd332a924420d9653f71c675acd2fdb9030f4384a9a33e256eb72237abb1fbb56', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-17 20:39:57'),
(100, 13, '9c044f071956ae6b38c7f26316ab46857a6759dd9bf26c5fc54e3d264ed760e5', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-17 20:40:34'),
(101, 13, '9c044f071956ae6b38c7f26316ab46857a6759dd9bf26c5fc54e3d264ed760e5', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-17 20:40:34'),
(102, 13, '48b7f478f2a2dfa7076f9b6e80f804e5aaf280466132c946074234892348095f', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-17 20:43:39'),
(103, 13, '48b7f478f2a2dfa7076f9b6e80f804e5aaf280466132c946074234892348095f', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-17 20:43:39'),
(104, 13, '584a1cad15081a1b4074644fd690427cc84ae1529e5200c248c69cf293a133dd', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-17 20:44:02'),
(105, 13, '584a1cad15081a1b4074644fd690427cc84ae1529e5200c248c69cf293a133dd', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-17 20:44:02'),
(106, 13, '3212db8182c90334c6718f35626babdbfd3a3230dac44323415df899eabdd09e', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-17 20:46:48'),
(107, 13, '3212db8182c90334c6718f35626babdbfd3a3230dac44323415df899eabdd09e', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-17 20:46:48'),
(108, 13, 'd9198265179f0df91d34b07e9f6d2acb4c3d1b83eed57af06454f2b6a83a126e', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-17 21:10:46'),
(109, 13, 'd9198265179f0df91d34b07e9f6d2acb4c3d1b83eed57af06454f2b6a83a126e', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-17 21:10:46'),
(110, 13, '06facf4d0551458341f0f3ec0f908562f5199ae7e4045955bfac42ce484d79ff', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 20:08:35'),
(111, 13, '8b3dcf72cad3339108fc1fe0209dd715dae672e112671d8355089e6b136991fa', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 20:17:07'),
(112, 13, '8b3dcf72cad3339108fc1fe0209dd715dae672e112671d8355089e6b136991fa', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 20:17:07'),
(113, 13, 'ab1fde14f360688a578cb2c1cea9462a3b079ab4d9e20697d0cf6a08f4367844', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 20:25:39'),
(114, 13, 'ab1fde14f360688a578cb2c1cea9462a3b079ab4d9e20697d0cf6a08f4367844', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 20:25:39'),
(115, 13, '92fca6ab32f8d04d5855355c3e0d35f1ecc574ae40f8218e4fe720425206b60b', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 20:27:27'),
(116, 13, '92fca6ab32f8d04d5855355c3e0d35f1ecc574ae40f8218e4fe720425206b60b', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 20:27:27'),
(117, 13, '91f9d562d5cf6beef738c353f8da3d477b2a0683cafd0df0151a185308dd7cd1', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 20:38:29'),
(118, 13, '91f9d562d5cf6beef738c353f8da3d477b2a0683cafd0df0151a185308dd7cd1', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 20:38:29'),
(119, 13, 'e106306cf84683848f636e5d04e0495c52d68431709aa0961cffdf3276d18d91', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 20:57:31'),
(120, 13, 'e106306cf84683848f636e5d04e0495c52d68431709aa0961cffdf3276d18d91', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 20:57:31'),
(121, 13, '3c982d0253b3462661ee435f32440619fdd8c37a9da90ff75486cb4c296b8f31', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 20:57:47'),
(122, 13, '3c982d0253b3462661ee435f32440619fdd8c37a9da90ff75486cb4c296b8f31', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 20:57:47'),
(123, 13, 'f8420235464b496f09b198c07be77f0d90355f3156f929ca527a1b374a787657', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 21:07:55'),
(124, 13, 'f8420235464b496f09b198c07be77f0d90355f3156f929ca527a1b374a787657', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 21:07:55'),
(125, 13, 'b5bbd965931c8290ac8775bffa0a59a6cbb5746a2bf594266b6bfddba63c99b9', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 21:09:35'),
(126, 13, 'b5bbd965931c8290ac8775bffa0a59a6cbb5746a2bf594266b6bfddba63c99b9', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 21:09:35'),
(127, 13, '2205617cd9cccb3d2aca8482d9028747fadaf3ee41ec427cc22e5f70c5295d6d', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 21:09:52'),
(128, 13, '2205617cd9cccb3d2aca8482d9028747fadaf3ee41ec427cc22e5f70c5295d6d', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 21:09:52'),
(129, 13, '9994c0c78c6427e065639f4e93ed40e0db1a5686e4457c827dbc6e8be42de1fc', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 21:13:14'),
(130, 13, '9994c0c78c6427e065639f4e93ed40e0db1a5686e4457c827dbc6e8be42de1fc', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 21:13:14'),
(131, 13, 'bc72c4d9ad2bfc1c8cd02b5008aa5f51672ef3429d7ba98f858b9340b86c8ce1', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 21:14:33'),
(132, 13, 'bc72c4d9ad2bfc1c8cd02b5008aa5f51672ef3429d7ba98f858b9340b86c8ce1', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 21:14:33'),
(133, 13, '6c8610b8bf15a6009f3f30b7bbf698a0293597b0d95f1d12d2659ad08aceaac1', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 21:37:37'),
(134, 13, '6c8610b8bf15a6009f3f30b7bbf698a0293597b0d95f1d12d2659ad08aceaac1', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 21:37:37'),
(135, 13, '991f24feb256c44eb9b6c0570f3e5959652075360861e369eb1c7200ed564887', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 21:38:51'),
(136, 13, '991f24feb256c44eb9b6c0570f3e5959652075360861e369eb1c7200ed564887', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 21:38:51'),
(137, 13, '201037d24dd308b8346d8df15898f2bebf82b223f0d54928e897477b5d64232a', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 21:42:59'),
(138, 13, '04e4dc4b47afb5f5943d47d94eac9ec36d0cb96db98f6c3c21618c014488d608', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 21:43:19'),
(139, 13, '04e4dc4b47afb5f5943d47d94eac9ec36d0cb96db98f6c3c21618c014488d608', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 21:43:19'),
(140, 13, 'b28689d1c5db32251902d6f1884f5aed41f20713be5b4f2c5cd1c20b0571aa7d', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 21:50:31'),
(141, 13, 'b28689d1c5db32251902d6f1884f5aed41f20713be5b4f2c5cd1c20b0571aa7d', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 21:50:31'),
(142, 13, 'ddb9c5a21d23b8feb43a875c8d1949f520881c60c74f74cf993a73766707db7c', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 22:02:53'),
(143, 13, 'ddb9c5a21d23b8feb43a875c8d1949f520881c60c74f74cf993a73766707db7c', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 22:02:53'),
(144, 13, 'b99879088a26b4c157c0ac44f78e29350e0f83d2d55439f2eb9278d19e4db668', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 22:09:29'),
(145, 13, 'b99879088a26b4c157c0ac44f78e29350e0f83d2d55439f2eb9278d19e4db668', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 22:09:29'),
(146, 13, '175e3f102555d5719e5a9c8ba401e09397bfa9c452dea25c09493d1b65c840e7', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 22:11:03'),
(147, 13, '175e3f102555d5719e5a9c8ba401e09397bfa9c452dea25c09493d1b65c840e7', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 22:11:03'),
(148, 13, '9d73695f3869658bf2620f00317a38a895e6388c177a88cc02013da3e7b13920', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 22:13:37'),
(149, 13, '9d73695f3869658bf2620f00317a38a895e6388c177a88cc02013da3e7b13920', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-18 22:13:37'),
(150, 13, '8645986f94b1ba594e1465bdebce555ff73cf27710da7beeec2285e26670ba92', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-23 22:48:33'),
(151, 13, '8645986f94b1ba594e1465bdebce555ff73cf27710da7beeec2285e26670ba92', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-23 22:48:33'),
(152, 13, 'ca5f48fcdd639f275e108181e032b2fafe6ad3122e3f98eeec7c2558c37584c6', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-23 22:54:34'),
(153, 13, 'ca5f48fcdd639f275e108181e032b2fafe6ad3122e3f98eeec7c2558c37584c6', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-23 22:54:34'),
(154, 13, '16f58a5fbc4af07fae0cf5740c6b2ebefb9cfaf6ce9bc41c924ee31f25fa2709', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-23 22:54:47'),
(155, 13, 'dfff25bdf15d17834515920c037874feade9266a15197217e413e5dc66233846', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-23 22:56:06'),
(156, 13, '82ea1549719fcf990b09eb9c2a410772574f606ca7cef4e2ee11803d933841ce', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-23 22:56:30'),
(157, 13, '52485893f96e59ee852bce05f8a932ee8524ca818f52d6019c4f0fbfd8f534dc', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-23 23:30:28'),
(158, 13, '52485893f96e59ee852bce05f8a932ee8524ca818f52d6019c4f0fbfd8f534dc', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-23 23:30:28'),
(159, 13, '18f70779c27316260d98e994941bcd660ade415e4f73be169ead884217035e24', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-23 23:40:03'),
(160, 13, '18f70779c27316260d98e994941bcd660ade415e4f73be169ead884217035e24', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-23 23:40:03'),
(161, 13, '241a2cd999ab7b4b033c8b24af17c2d42123bc6a1bcb849f6b416bb213b99e0c', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-23 23:57:18'),
(162, 13, '241a2cd999ab7b4b033c8b24af17c2d42123bc6a1bcb849f6b416bb213b99e0c', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-23 23:57:18'),
(163, 13, '5667a5cf317b6e3def6f93f50b19e676574171856b301e800c6015295cdc016c', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-24 19:03:31'),
(164, 13, '5667a5cf317b6e3def6f93f50b19e676574171856b301e800c6015295cdc016c', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-24 19:03:31'),
(165, 13, 'd7cbd41ced96fe229a536269df5049826585c2ab40e3e16a717c7afef06113b5', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-24 19:06:50'),
(166, 13, 'd7cbd41ced96fe229a536269df5049826585c2ab40e3e16a717c7afef06113b5', '84ef9b57-8b3c-4a6a-8da6-e6fa97b357ea', '0000-00-00 00:00:00', '2026-09-24 19:07:00', '2026-09-24 19:06:50'),
(167, 14, '382d2ee16e9df968599cc706d03bb8d6a9c3ec61ca99d3e0fd18f2243bf4fe25', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 19:07:00'),
(168, 14, '758cc3d63890123ddd5b80da482bef62775232be1297483c85a63681674921a9', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 19:11:25'),
(169, 14, '758cc3d63890123ddd5b80da482bef62775232be1297483c85a63681674921a9', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 19:11:25'),
(170, 14, 'f021151181c337ba8bf952217a831ff2a5534ddfc6be3aebbaab776223b9eb9a', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 19:11:40'),
(171, 14, '8bdd771bda81aa075e46de8040df65c00e460b092f383b615e46f89b1de56e14', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 19:16:17'),
(172, 14, '8bdd771bda81aa075e46de8040df65c00e460b092f383b615e46f89b1de56e14', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 19:16:17'),
(173, 14, '07167b693086149ac079d5f52a5d929648c98cf8bf0bafba22f76ad19ee4964b', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 19:27:18'),
(174, 14, '07167b693086149ac079d5f52a5d929648c98cf8bf0bafba22f76ad19ee4964b', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 19:27:18'),
(175, 14, '61dcb0785c6c18dda0785e8d66dd3585935a2bd6841433b6733e63beb8a39aac', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 19:28:19'),
(176, 14, '61dcb0785c6c18dda0785e8d66dd3585935a2bd6841433b6733e63beb8a39aac', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 19:28:19'),
(177, 14, '34d0f33aa56cb60d86e946d64db95ef5cf9bdb6aa9ff752d7d491ad2081249fa', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 20:01:45'),
(178, 14, '34d0f33aa56cb60d86e946d64db95ef5cf9bdb6aa9ff752d7d491ad2081249fa', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 20:01:45'),
(179, 14, 'ddc38a417e08d59491e4b9688f0b08578f4ae59581d5678aab3771f283283b75', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 20:13:08'),
(180, 14, 'ddc38a417e08d59491e4b9688f0b08578f4ae59581d5678aab3771f283283b75', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 20:13:08'),
(181, 14, '7e0250ab52e615210d77eff50e5fce93102ef5d4c2793ad5ab193b585ea634c6', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 20:22:01'),
(182, 14, '7e0250ab52e615210d77eff50e5fce93102ef5d4c2793ad5ab193b585ea634c6', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 20:22:01'),
(183, 14, '80377adc0051036582ea0e7833c2af7f03cd1c63bae29f4c91a51f3dc13e8ae7', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 20:22:49'),
(184, 14, 'b8a422a48f5bc3f2b636984bc5d2985df08b1a88a9ab73bf1dc9a55f4b928e99', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 20:22:53'),
(185, 14, '26978503eab7f4a8e1cd95bc5f87acf148b9e5364f23a6c083fcb066cbde2e1c', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 20:24:59'),
(186, 14, '26978503eab7f4a8e1cd95bc5f87acf148b9e5364f23a6c083fcb066cbde2e1c', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 20:24:59'),
(187, 14, '3b08aeaacb83524da686a72456eaad0bd37a5acf4ea29300e704f8465c309590', '222b8a01-fb25-4da2-89d2-022061615f2c', '0000-00-00 00:00:00', '2026-09-24 20:25:53', '2026-09-24 20:25:29'),
(188, 15, '4309d7bb5b7abd00e2f340fa14c67036dc948d8a4ac5d7928e93b9fdc3367717', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:25:55'),
(189, 15, '4d6b06f91a8ebacae2b086f8e74d05f576e9650a07c28578f64ac3393b2cc5f9', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:26:25'),
(190, 15, '7ca0f0ac3242a49151fa072c1e76ae8cebc772a9c05b220491cc151714cc3794', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:26:26'),
(191, 15, '0337f89becdfad272c3b203fc401aacbc3ffcf2e149c16b21baf777074bc64b2', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:26:41'),
(192, 15, '0337f89becdfad272c3b203fc401aacbc3ffcf2e149c16b21baf777074bc64b2', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:26:41'),
(193, 15, '8999615432aa7664598f1b944fc1b3e8ae9823b56e1d88d92f6aeca4112c27cc', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:30:31'),
(194, 15, '8999615432aa7664598f1b944fc1b3e8ae9823b56e1d88d92f6aeca4112c27cc', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:30:31'),
(195, 15, '57014f583866d535151864bfd05e7d36a66ddedeeabad26abcd393c4da409910', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:40:28'),
(196, 15, '57014f583866d535151864bfd05e7d36a66ddedeeabad26abcd393c4da409910', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:40:28'),
(197, 15, '42260009e63d917d1c1a3e9625f94b19ae831aad9d935c3a4ba0a22d2d0f6c16', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:44:01'),
(198, 15, '42260009e63d917d1c1a3e9625f94b19ae831aad9d935c3a4ba0a22d2d0f6c16', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:44:01'),
(199, 15, 'd6d3cf33201d140e99cd3cdae624e341d325f126e11f3ff13f9d64702d885cef', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:48:33'),
(200, 15, 'd6d3cf33201d140e99cd3cdae624e341d325f126e11f3ff13f9d64702d885cef', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:48:33'),
(201, 15, 'fb42c10819411f5840cc9e6fa866ef1a0cde8883edad9c6029a75d429c412dd8', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:49:47'),
(202, 15, 'fb42c10819411f5840cc9e6fa866ef1a0cde8883edad9c6029a75d429c412dd8', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:49:47'),
(203, 15, '95770a952e4450fe25cf9e5aeffc70b2001c1f1249ffe3b488e6a7e2bee5e6d9', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:52:44'),
(204, 15, '95770a952e4450fe25cf9e5aeffc70b2001c1f1249ffe3b488e6a7e2bee5e6d9', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:52:44'),
(205, 15, '013c9c13da3fb313b0e4d084badb8e5d26bc33ff41551315b237c1c5a0528f21', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:53:14'),
(206, 15, '013c9c13da3fb313b0e4d084badb8e5d26bc33ff41551315b237c1c5a0528f21', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:53:14'),
(207, 15, '39f8e41d26ed920decef56b916f3b7078d573db57d400ebe44f055a98260c613', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:56:29'),
(208, 15, '39f8e41d26ed920decef56b916f3b7078d573db57d400ebe44f055a98260c613', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 20:56:29'),
(209, 15, '489e5011f6ea7af2ac72c99adb6a41d3b7498017405ecbc2dfee4f30c23e84a6', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 21:12:09'),
(210, 15, '489e5011f6ea7af2ac72c99adb6a41d3b7498017405ecbc2dfee4f30c23e84a6', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 21:12:09'),
(211, 15, 'e6c0ab683b82332ba059513eda45c5627c097d69782487bcb915b6d0d9cc49ba', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 21:14:34'),
(212, 15, 'e6c0ab683b82332ba059513eda45c5627c097d69782487bcb915b6d0d9cc49ba', 'd1461f63-b9ec-4823-a210-b9a71a105100', '0000-00-00 00:00:00', NULL, '2026-09-24 21:14:34');

-- --------------------------------------------------------

--
-- Table structure for table `reminder_preferences`
--

CREATE TABLE `reminder_preferences` (
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `fertile_days_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `pregnancy_test_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `daily_tips_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `period_reminder_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `reminder_preferences`
--

INSERT INTO `reminder_preferences` (`user_id`, `fertile_days_enabled`, `pregnancy_test_enabled`, `daily_tips_enabled`, `period_reminder_enabled`, `created_at`, `updated_at`) VALUES
(2, 1, 0, 1, 1, '2026-09-14 22:07:40', '2026-09-14 22:07:40'),
(8, 1, 0, 1, 1, '2026-09-17 20:15:06', '2026-09-17 20:15:06'),
(10, 1, 0, 1, 1, '2026-09-17 20:17:26', '2026-09-17 20:17:26'),
(13, 1, 0, 1, 1, '2026-09-17 20:44:27', '2026-09-17 20:44:27'),
(14, 1, 0, 1, 1, '2026-09-24 19:15:48', '2026-09-24 19:15:48'),
(15, 1, 0, 1, 1, '2026-09-24 20:31:57', '2026-09-24 20:31:57');

-- --------------------------------------------------------

--
-- Table structure for table `secret_profiles`
--

CREATE TABLE `secret_profiles` (
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `username` varchar(40) NOT NULL,
  `avatar_url` varchar(512) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `secret_profiles`
--

INSERT INTO `secret_profiles` (`user_id`, `username`, `avatar_url`, `created_at`, `updated_at`) VALUES
(13, 'zohaib', NULL, '2026-09-18 21:13:54', '2026-09-18 21:13:54');

-- --------------------------------------------------------

--
-- Table structure for table `secret_profile_tags`
--

CREATE TABLE `secret_profile_tags` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `tag_key` varchar(64) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `secret_profile_tags`
--

INSERT INTO `secret_profile_tags` (`id`, `user_id`, `tag_key`, `created_at`) VALUES
(1, 13, 'Postpartum', '2026-09-18 21:13:54'),
(2, 13, 'Mood & mental health', '2026-09-18 21:13:54');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `account_status` enum('guest','registered') NOT NULL DEFAULT 'guest',
  `email` varchar(255) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `name` varchar(120) DEFAULT NULL,
  `google_sub` varchar(255) DEFAULT NULL,
  `email_verified_at` datetime DEFAULT NULL,
  `registered_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `account_status`, `email`, `password_hash`, `name`, `google_sub`, `email_verified_at`, `registered_at`, `last_login_at`, `is_active`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'guest', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-14 20:08:19', 1, '2026-09-14 20:08:19', '2026-09-14 20:08:19', NULL),
(2, 'guest', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-17 19:17:28', 1, '2026-09-14 20:08:27', '2026-09-17 19:17:28', NULL),
(3, 'guest', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-14 20:13:09', 1, '2026-09-14 20:13:09', '2026-09-14 20:13:09', NULL),
(4, 'guest', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-14 20:14:35', 1, '2026-09-14 20:14:35', '2026-09-14 20:14:35', NULL),
(5, 'guest', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-16 18:29:36', 1, '2026-09-16 18:29:36', '2026-09-16 18:29:36', NULL),
(6, 'guest', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-17 20:11:05', 1, '2026-09-17 19:37:59', '2026-09-17 20:11:05', NULL),
(8, 'guest', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-17 20:13:51', 1, '2026-09-17 20:13:45', '2026-09-17 20:13:51', NULL),
(10, 'guest', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-17 20:30:05', 1, '2026-09-17 20:16:19', '2026-09-17 20:30:05', NULL),
(13, 'registered', 'zohaib@gmail.com', '$2b$10$nfgAiBz/9W5XJGqWeGqfYuf/67O2h6dTXyRdg3Uw9BwUHUhJgXwuy', NULL, NULL, NULL, '2026-09-18 21:42:59', '2026-09-24 19:06:50', 1, '2026-09-17 20:31:39', '2026-09-24 19:06:50', NULL),
(14, 'guest', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-24 20:25:29', 1, '2026-09-24 19:07:00', '2026-09-24 20:25:29', NULL),
(15, 'guest', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-24 21:14:34', 1, '2026-09-24 20:25:55', '2026-09-24 21:14:34', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_consents`
--

CREATE TABLE `user_consents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `consent_type` enum('terms','health_data','marketing','notifications') NOT NULL,
  `accepted` tinyint(1) NOT NULL,
  `accepted_at` datetime NOT NULL,
  `document_version` varchar(32) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_consents`
--

INSERT INTO `user_consents` (`id`, `user_id`, `consent_type`, `accepted`, `accepted_at`, `document_version`, `created_at`, `updated_at`) VALUES
(1, 2, 'terms', 1, '2026-09-14 20:57:33', NULL, '2026-09-14 20:09:37', '2026-09-14 20:57:33'),
(2, 2, 'health_data', 1, '2026-09-14 20:57:33', NULL, '2026-09-14 20:09:37', '2026-09-14 20:57:33'),
(13, 6, 'terms', 1, '2026-09-17 20:02:21', NULL, '2026-09-17 20:02:21', '2026-09-17 20:02:21'),
(14, 6, 'health_data', 1, '2026-09-17 20:02:21', NULL, '2026-09-17 20:02:21', '2026-09-17 20:02:21'),
(15, 8, 'terms', 1, '2026-09-17 20:13:51', NULL, '2026-09-17 20:13:51', '2026-09-17 20:13:51'),
(16, 8, 'health_data', 1, '2026-09-17 20:13:51', NULL, '2026-09-17 20:13:51', '2026-09-17 20:13:51'),
(17, 10, 'terms', 1, '2026-09-17 20:16:25', NULL, '2026-09-17 20:16:25', '2026-09-17 20:16:25'),
(18, 10, 'health_data', 1, '2026-09-17 20:16:25', NULL, '2026-09-17 20:16:25', '2026-09-17 20:16:25'),
(19, 13, 'terms', 1, '2026-09-18 20:08:35', NULL, '2026-09-17 20:35:58', '2026-09-18 20:08:35'),
(20, 13, 'health_data', 1, '2026-09-18 20:08:35', NULL, '2026-09-17 20:35:58', '2026-09-18 20:08:35'),
(23, 14, 'terms', 1, '2026-09-24 19:11:40', NULL, '2026-09-24 19:11:40', '2026-09-24 19:11:40'),
(24, 14, 'health_data', 1, '2026-09-24 19:11:40', NULL, '2026-09-24 19:11:40', '2026-09-24 19:11:40'),
(25, 15, 'terms', 1, '2026-09-24 20:26:27', NULL, '2026-09-24 20:26:27', '2026-09-24 20:26:27'),
(26, 15, 'health_data', 1, '2026-09-24 20:26:27', NULL, '2026-09-24 20:26:27', '2026-09-24 20:26:27');

-- --------------------------------------------------------

--
-- Table structure for table `user_goals`
--

CREATE TABLE `user_goals` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `goal_key` varchar(64) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_goals`
--

INSERT INTO `user_goals` (`id`, `user_id`, `goal_key`, `created_at`) VALUES
(15, 2, 'get_pregnant', '2026-09-14 20:57:44'),
(16, 2, 'track_pregnancy', '2026-09-14 20:57:44'),
(17, 2, 'well_being', '2026-09-14 20:57:44'),
(18, 2, 'track_period', '2026-09-14 20:57:44'),
(21, 8, 'get_pregnant', '2026-09-17 20:15:06'),
(22, 8, 'track_pregnancy', '2026-09-17 20:15:06'),
(26, 13, 'get_pregnant', '2026-09-18 20:09:58'),
(27, 13, 'track_pregnancy', '2026-09-18 20:09:58'),
(28, 13, 'track_period', '2026-09-18 20:09:58'),
(33, 14, 'track_pregnancy', '2026-09-24 19:15:48'),
(34, 14, 'get_pregnant', '2026-09-24 19:15:48'),
(35, 14, 'track_period', '2026-09-24 19:15:48'),
(36, 14, 'well_being', '2026-09-24 19:15:48'),
(40, 15, 'track_pregnancy', '2026-09-24 20:31:57'),
(41, 15, 'get_pregnant', '2026-09-24 20:31:57'),
(42, 15, 'track_period', '2026-09-24 20:31:57');

-- --------------------------------------------------------

--
-- Table structure for table `user_profiles`
--

CREATE TABLE `user_profiles` (
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `birth_year` smallint(6) DEFAULT NULL,
  `height_cm` decimal(5,2) DEFAULT NULL,
  `weight_kg` decimal(5,2) DEFAULT NULL,
  `is_metric` tinyint(1) NOT NULL DEFAULT 1,
  `experience_mode` enum('track_cycle','get_pregnant','track_pregnancy','perimenopause','partner') DEFAULT NULL,
  `pregnancy_mode_active` tinyint(1) NOT NULL DEFAULT 0,
  `due_date` date DEFAULT NULL,
  `lmp_based_edd` date DEFAULT NULL COMMENT 'LMP + 280 days snapshot',
  `clinician_edd` date DEFAULT NULL COMMENT 'Clinician or ultrasound EDD entered by user',
  `edd_source` enum('lmp','clinician_ultrasound') DEFAULT NULL COMMENT 'Which source is active for due_date',
  `discovery_source` varchar(64) DEFAULT NULL,
  `usage_path` enum('self','partner') DEFAULT NULL,
  `partner_code_entered` varchar(16) DEFAULT NULL,
  `avg_cycle_length` tinyint(4) DEFAULT 28,
  `avg_period_length` tinyint(4) DEFAULT 5,
  `luteal_phase_days` tinyint(4) NOT NULL DEFAULT 14,
  `fertile_window_mode` enum('standard','wide') NOT NULL DEFAULT 'standard',
  `timezone` varchar(64) DEFAULT NULL,
  `onboarding_completed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_profiles`
--

INSERT INTO `user_profiles` (`user_id`, `birth_year`, `height_cm`, `weight_kg`, `is_metric`, `experience_mode`, `pregnancy_mode_active`, `due_date`, `lmp_based_edd`, `clinician_edd`, `edd_source`, `discovery_source`, `usage_path`, `partner_code_entered`, `avg_cycle_length`, `avg_period_length`, `luteal_phase_days`, `fertile_window_mode`, `timezone`, `onboarding_completed_at`, `created_at`, `updated_at`) VALUES
(1, NULL, NULL, NULL, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 28, 5, 14, 'standard', NULL, NULL, '2026-09-14 20:08:19', '2026-09-14 20:08:19'),
(2, 2001, 170.00, 65.00, 1, 'track_cycle', 0, '2027-06-11', NULL, NULL, NULL, 'Online Advertisement', 'self', NULL, 28, 5, 14, 'wide', 'UTC+05:00', '2026-09-16 19:10:05', '2026-09-14 20:08:27', '2026-09-16 19:10:05'),
(3, NULL, NULL, NULL, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 28, 5, 14, 'standard', NULL, NULL, '2026-09-14 20:13:09', '2026-09-14 20:13:09'),
(4, NULL, NULL, NULL, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 28, 5, 14, 'standard', NULL, NULL, '2026-09-14 20:14:35', '2026-09-14 20:14:35'),
(5, NULL, NULL, NULL, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 28, 5, 14, 'standard', NULL, NULL, '2026-09-16 18:29:36', '2026-09-16 18:29:36'),
(6, NULL, NULL, NULL, 1, 'partner', 0, NULL, NULL, NULL, NULL, NULL, 'partner', NULL, 28, 5, 14, 'standard', NULL, '2026-09-17 20:04:56', '2026-09-17 19:37:59', '2026-09-17 20:04:56'),
(8, 2001, 170.00, 65.00, 1, 'track_pregnancy', 0, NULL, NULL, NULL, NULL, 'Google Play or Google Search', 'self', NULL, 28, 4, 14, 'wide', 'UTC+05:00', '2026-09-17 20:15:06', '2026-09-17 20:13:46', '2026-09-17 20:15:06'),
(10, 2001, 170.00, 65.00, 1, 'partner', 0, NULL, NULL, NULL, NULL, NULL, 'partner', 'P4UMJK', 28, 5, 14, 'standard', 'UTC+05:00', '2026-09-17 20:17:26', '2026-09-17 20:16:19', '2026-09-17 20:17:26'),
(13, 2001, 170.00, 65.00, 1, 'track_pregnancy', 0, NULL, NULL, NULL, NULL, 'Instagram or Facebook', 'self', 'P4UMJK', 28, 5, 14, 'wide', 'UTC+05:00', '2026-09-18 20:09:58', '2026-09-17 20:31:40', '2026-09-18 20:09:58'),
(14, 2001, 170.00, 65.00, 1, 'track_pregnancy', 0, NULL, NULL, NULL, NULL, 'Google Play or Google Search', 'self', NULL, 28, 5, 14, 'wide', 'UTC+05:00', '2026-09-24 19:15:48', '2026-09-24 19:07:00', '2026-09-24 19:15:48'),
(15, 2001, 170.00, 65.00, 1, 'get_pregnant', 0, NULL, NULL, NULL, NULL, 'Google Play or Google Search', 'self', NULL, 31, 5, 14, 'wide', 'UTC+05:00', '2026-09-24 21:14:11', '2026-09-24 20:25:55', '2026-09-24 21:14:25');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `article_bookmarks`
--
ALTER TABLE `article_bookmarks`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_article_bookmarks_user_article` (`user_id`,`article_id`),
  ADD KEY `idx_article_bookmarks_user` (`user_id`);

--
-- Indexes for table `comment_likes`
--
ALTER TABLE `comment_likes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_comment_likes_comment_user` (`comment_id`,`user_id`),
  ADD KEY `idx_comment_likes_user` (`user_id`);

--
-- Indexes for table `cycles`
--
ALTER TABLE `cycles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_cycles_user_start` (`user_id`,`start_date`);

--
-- Indexes for table `cycle_observations`
--
ALTER TABLE `cycle_observations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_cycle_obs_user_date_type` (`user_id`,`obs_date`,`observation_type`),
  ADD KEY `idx_cycle_obs_user_date` (`user_id`,`obs_date`),
  ADD KEY `idx_cycle_obs_user_type` (`user_id`,`observation_type`);

--
-- Indexes for table `cycle_predictions`
--
ALTER TABLE `cycle_predictions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_cycle_predictions_user_date_type` (`user_id`,`pred_date`,`prediction_type`),
  ADD KEY `idx_cycle_predictions_user_date` (`user_id`,`pred_date`);

--
-- Indexes for table `daily_logs`
--
ALTER TABLE `daily_logs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_daily_logs_user_date` (`user_id`,`log_date`),
  ADD KEY `idx_daily_logs_user_date` (`user_id`,`log_date`);

--
-- Indexes for table `daily_log_items`
--
ALTER TABLE `daily_log_items`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_daily_log_items_log_key` (`daily_log_id`,`item_key`),
  ADD KEY `idx_daily_log_items_log` (`daily_log_id`);

--
-- Indexes for table `devices`
--
ALTER TABLE `devices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_devices_device_id` (`device_id`),
  ADD KEY `idx_devices_user_id` (`user_id`);

--
-- Indexes for table `onboarding_answers`
--
ALTER TABLE `onboarding_answers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_onboarding_answers_user_flow_step` (`user_id`,`flow_key`,`step_id`),
  ADD KEY `idx_onboarding_answers_user_id` (`user_id`);

--
-- Indexes for table `partner_links`
--
ALTER TABLE `partner_links`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_partner_links_owner` (`owner_user_id`),
  ADD KEY `idx_partner_links_partner` (`partner_user_id`),
  ADD KEY `idx_partner_links_status` (`status`),
  ADD KEY `idx_partner_links_code` (`code`);

--
-- Indexes for table `period_days`
--
ALTER TABLE `period_days`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_period_days_user_date` (`user_id`,`log_date`),
  ADD KEY `idx_period_days_cycle_id` (`cycle_id`);

--
-- Indexes for table `posts`
--
ALTER TABLE `posts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_posts_created` (`created_at`),
  ADD KEY `idx_posts_user` (`user_id`);

--
-- Indexes for table `post_comments`
--
ALTER TABLE `post_comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_post_comments_post` (`post_id`),
  ADD KEY `idx_post_comments_user` (`user_id`);

--
-- Indexes for table `post_likes`
--
ALTER TABLE `post_likes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_post_likes_post_user` (`post_id`,`user_id`),
  ADD KEY `idx_post_likes_user` (`user_id`);

--
-- Indexes for table `prediction_validation_log`
--
ALTER TABLE `prediction_validation_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pvl_user_date` (`user_id`,`actual_date`),
  ADD KEY `idx_pvl_event` (`event_type`,`created_at`);

--
-- Indexes for table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_refresh_tokens_user_id` (`user_id`),
  ADD KEY `idx_refresh_tokens_token_hash` (`token_hash`);

--
-- Indexes for table `reminder_preferences`
--
ALTER TABLE `reminder_preferences`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `secret_profiles`
--
ALTER TABLE `secret_profiles`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `uq_secret_profiles_username` (`username`);

--
-- Indexes for table `secret_profile_tags`
--
ALTER TABLE `secret_profile_tags`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_secret_profile_tags_user_tag` (`user_id`,`tag_key`),
  ADD KEY `idx_secret_profile_tags_user` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_users_email` (`email`),
  ADD UNIQUE KEY `uq_users_google_sub` (`google_sub`),
  ADD KEY `idx_users_account_status` (`account_status`);

--
-- Indexes for table `user_consents`
--
ALTER TABLE `user_consents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_consents_user_type` (`user_id`,`consent_type`);

--
-- Indexes for table `user_goals`
--
ALTER TABLE `user_goals`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_goals_user_key` (`user_id`,`goal_key`),
  ADD KEY `idx_user_goals_user_id` (`user_id`);

--
-- Indexes for table `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `article_bookmarks`
--
ALTER TABLE `article_bookmarks`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `comment_likes`
--
ALTER TABLE `comment_likes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `cycles`
--
ALTER TABLE `cycles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `cycle_observations`
--
ALTER TABLE `cycle_observations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2039;

--
-- AUTO_INCREMENT for table `cycle_predictions`
--
ALTER TABLE `cycle_predictions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8621;

--
-- AUTO_INCREMENT for table `daily_logs`
--
ALTER TABLE `daily_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `daily_log_items`
--
ALTER TABLE `daily_log_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `devices`
--
ALTER TABLE `devices`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `onboarding_answers`
--
ALTER TABLE `onboarding_answers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=96;

--
-- AUTO_INCREMENT for table `partner_links`
--
ALTER TABLE `partner_links`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `period_days`
--
ALTER TABLE `period_days`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1328;

--
-- AUTO_INCREMENT for table `posts`
--
ALTER TABLE `posts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `post_comments`
--
ALTER TABLE `post_comments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `post_likes`
--
ALTER TABLE `post_likes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `prediction_validation_log`
--
ALTER TABLE `prediction_validation_log`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT for table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=213;

--
-- AUTO_INCREMENT for table `secret_profile_tags`
--
ALTER TABLE `secret_profile_tags`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `user_consents`
--
ALTER TABLE `user_consents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `user_goals`
--
ALTER TABLE `user_goals`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `article_bookmarks`
--
ALTER TABLE `article_bookmarks`
  ADD CONSTRAINT `fk_article_bookmarks_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `comment_likes`
--
ALTER TABLE `comment_likes`
  ADD CONSTRAINT `fk_comment_likes_comment` FOREIGN KEY (`comment_id`) REFERENCES `post_comments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_comment_likes_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `cycles`
--
ALTER TABLE `cycles`
  ADD CONSTRAINT `fk_cycles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `cycle_observations`
--
ALTER TABLE `cycle_observations`
  ADD CONSTRAINT `fk_cycle_observations_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `cycle_predictions`
--
ALTER TABLE `cycle_predictions`
  ADD CONSTRAINT `fk_cycle_predictions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `daily_logs`
--
ALTER TABLE `daily_logs`
  ADD CONSTRAINT `fk_daily_logs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `daily_log_items`
--
ALTER TABLE `daily_log_items`
  ADD CONSTRAINT `fk_daily_log_items_log` FOREIGN KEY (`daily_log_id`) REFERENCES `daily_logs` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `devices`
--
ALTER TABLE `devices`
  ADD CONSTRAINT `fk_devices_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `onboarding_answers`
--
ALTER TABLE `onboarding_answers`
  ADD CONSTRAINT `fk_onboarding_answers_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `partner_links`
--
ALTER TABLE `partner_links`
  ADD CONSTRAINT `fk_partner_links_owner` FOREIGN KEY (`owner_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_partner_links_partner` FOREIGN KEY (`partner_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `period_days`
--
ALTER TABLE `period_days`
  ADD CONSTRAINT `fk_period_days_cycle` FOREIGN KEY (`cycle_id`) REFERENCES `cycles` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_period_days_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `posts`
--
ALTER TABLE `posts`
  ADD CONSTRAINT `fk_posts_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `post_comments`
--
ALTER TABLE `post_comments`
  ADD CONSTRAINT `fk_post_comments_post` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_post_comments_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `post_likes`
--
ALTER TABLE `post_likes`
  ADD CONSTRAINT `fk_post_likes_post` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_post_likes_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `prediction_validation_log`
--
ALTER TABLE `prediction_validation_log`
  ADD CONSTRAINT `fk_pvl_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  ADD CONSTRAINT `fk_refresh_tokens_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `reminder_preferences`
--
ALTER TABLE `reminder_preferences`
  ADD CONSTRAINT `fk_reminder_preferences_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `secret_profiles`
--
ALTER TABLE `secret_profiles`
  ADD CONSTRAINT `fk_secret_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `secret_profile_tags`
--
ALTER TABLE `secret_profile_tags`
  ADD CONSTRAINT `fk_secret_profile_tags_profile` FOREIGN KEY (`user_id`) REFERENCES `secret_profiles` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `user_consents`
--
ALTER TABLE `user_consents`
  ADD CONSTRAINT `fk_user_consents_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_goals`
--
ALTER TABLE `user_goals`
  ADD CONSTRAINT `fk_user_goals_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD CONSTRAINT `fk_user_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
