-- MySQL dump 10.13  Distrib 5.1.31, for debian-linux-gnu (i486)
--
-- Host: localhost    Database: perldocjp
-- ------------------------------------------------------
-- Server version	5.1.31-1ubuntu2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `author`
--

DROP TABLE IF EXISTS `author`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `author` (
  `author_id` int(11) NOT NULL AUTO_INCREMENT,
  `author_uid` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `author_name` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `author_email` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`author_id`),
  UNIQUE KEY `author_uid` (`author_uid`)
) ENGINE=InnoDB AUTO_INCREMENT=7756 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `dist`
--

DROP TABLE IF EXISTS `dist`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `dist` (
  `dist_id` int(11) NOT NULL AUTO_INCREMENT,
  `author_name` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `dist_name` varchar(128) COLLATE utf8_unicode_ci NOT NULL,
  `latest_release` varchar(128) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`dist_id`)
) ENGINE=InnoDB AUTO_INCREMENT=261 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `dist_author`
--

DROP TABLE IF EXISTS `dist_author`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `dist_author` (
  `dist_id` int(11) NOT NULL,
  `author_id` int(11) NOT NULL,
  PRIMARY KEY (`dist_id`,`author_id`),
  KEY `dist_id` (`dist_id`),
  KEY `author_id` (`author_id`),
  CONSTRAINT `dist_author_ibfk_1` FOREIGN KEY (`dist_id`) REFERENCES `dist` (`dist_id`),
  CONSTRAINT `dist_author_ibfk_2` FOREIGN KEY (`author_id`) REFERENCES `author` (`author_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `document`
--

DROP TABLE IF EXISTS `document`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `document` (
  `doc_id` int(11) NOT NULL AUTO_INCREMENT,
  `doc_name` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `doc_loc` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `dist_id` int(11) NOT NULL,
  `is_module` tinyint(1) NOT NULL,
  `doc_desc` varchar(256) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`doc_id`),
  KEY `doc_loc` (`doc_loc`)
) ENGINE=InnoDB AUTO_INCREMENT=525 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `document_dist`
--

DROP TABLE IF EXISTS `document_dist`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `document_dist` (
  `document_id` int(11) NOT NULL,
  `dist_id` int(11) NOT NULL,
  PRIMARY KEY (`document_id`,`dist_id`),
  KEY `document_id` (`document_id`),
  KEY `dist_id` (`dist_id`),
  CONSTRAINT `document_dist_ibfk_1` FOREIGN KEY (`document_id`) REFERENCES `document` (`doc_id`),
  CONSTRAINT `document_dist_ibfk_2` FOREIGN KEY (`dist_id`) REFERENCES `dist` (`dist_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2009-12-02  6:22:16
