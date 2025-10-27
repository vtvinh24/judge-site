-- MySQL dump 10.13  Distrib 8.0.44, for Linux (x86_64)
--
-- Host: 127.0.0.1    Database: dmoj
-- ------------------------------------------------------
-- Server version	12.0.2-MariaDB-ubu2404

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `auth_group`
--

DROP TABLE IF EXISTS `auth_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auth_group_permissions`
--

DROP TABLE IF EXISTS `auth_group_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auth_permission`
--

DROP TABLE IF EXISTS `auth_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`),
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=262 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auth_user`
--

DROP TABLE IF EXISTS `auth_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `password` varchar(128) NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) NOT NULL,
  `first_name` varchar(150) NOT NULL,
  `last_name` varchar(150) NOT NULL,
  `email` varchar(254) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auth_user_groups`
--

DROP TABLE IF EXISTS `auth_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_groups_user_id_group_id_94350c0c_uniq` (`user_id`,`group_id`),
  KEY `auth_user_groups_group_id_97559544_fk_auth_group_id` (`group_id`),
  CONSTRAINT `auth_user_groups_group_id_97559544_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `auth_user_groups_user_id_6a12ed8b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auth_user_user_permissions`
--

DROP TABLE IF EXISTS `auth_user_user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user_user_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_user_permissions_user_id_permission_id_14a6b632_uniq` (`user_id`,`permission_id`),
  KEY `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext DEFAULT NULL,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint(5) unsigned NOT NULL CHECK (`action_flag` >= 0),
  `change_message` longtext NOT NULL,
  `content_type_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  KEY `django_admin_log_user_id_c564eba6_fk_auth_user_id` (`user_id`),
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `django_flatpage`
--

DROP TABLE IF EXISTS `django_flatpage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_flatpage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(100) NOT NULL,
  `title` varchar(200) NOT NULL,
  `content` longtext NOT NULL,
  `enable_comments` tinyint(1) NOT NULL,
  `template_name` varchar(70) NOT NULL,
  `registration_required` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_flatpage_url_41612362` (`url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `django_flatpage_sites`
--

DROP TABLE IF EXISTS `django_flatpage_sites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_flatpage_sites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `flatpage_id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_flatpage_sites_flatpage_id_site_id_0d29d9d1_uniq` (`flatpage_id`,`site_id`),
  KEY `django_flatpage_sites_site_id_bfd8ea84_fk_django_site_id` (`site_id`),
  CONSTRAINT `django_flatpage_sites_flatpage_id_078bbc8b_fk_django_flatpage_id` FOREIGN KEY (`flatpage_id`) REFERENCES `django_flatpage` (`id`),
  CONSTRAINT `django_flatpage_sites_site_id_bfd8ea84_fk_django_site_id` FOREIGN KEY (`site_id`) REFERENCES `django_site` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `django_migrations`
--

DROP TABLE IF EXISTS `django_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_migrations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=202 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `django_redirect`
--

DROP TABLE IF EXISTS `django_redirect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_redirect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `old_path` varchar(200) NOT NULL,
  `new_path` varchar(200) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_redirect_site_id_old_path_ac5dd16b_uniq` (`site_id`,`old_path`),
  KEY `django_redirect_old_path_c6cc94d3` (`old_path`),
  CONSTRAINT `django_redirect_site_id_c3e37341_fk_django_site_id` FOREIGN KEY (`site_id`) REFERENCES `django_site` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `django_session`
--

DROP TABLE IF EXISTS `django_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_expire_date_a5c62663` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `django_site`
--

DROP TABLE IF EXISTS `django_site`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_site` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain` varchar(100) NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_site_domain_a2e37b91_uniq` (`domain`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `impersonate_impersonationlog`
--

DROP TABLE IF EXISTS `impersonate_impersonationlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `impersonate_impersonationlog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_key` varchar(40) NOT NULL,
  `session_started_at` datetime(6) DEFAULT NULL,
  `session_ended_at` datetime(6) DEFAULT NULL,
  `impersonating_id` int(11) NOT NULL,
  `impersonator_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `impersonate_imperson_impersonating_id_afd114fc_fk_auth_user` (`impersonating_id`),
  KEY `impersonate_imperson_impersonator_id_1ecfe8ce_fk_auth_user` (`impersonator_id`),
  CONSTRAINT `impersonate_imperson_impersonating_id_afd114fc_fk_auth_user` FOREIGN KEY (`impersonating_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `impersonate_imperson_impersonator_id_1ecfe8ce_fk_auth_user` FOREIGN KEY (`impersonator_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_blogpost`
--

DROP TABLE IF EXISTS `judge_blogpost`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_blogpost` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `slug` varchar(50) NOT NULL,
  `visible` tinyint(1) NOT NULL,
  `sticky` tinyint(1) NOT NULL,
  `publish_on` datetime(6) NOT NULL,
  `content` longtext NOT NULL,
  `summary` longtext NOT NULL,
  `og_image` varchar(150) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `judge_blogpost_slug_eb303bae` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_blogpost_authors`
--

DROP TABLE IF EXISTS `judge_blogpost_authors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_blogpost_authors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `blogpost_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_blogpost_authors_blogpost_id_profile_id_e53f2daf_uniq` (`blogpost_id`,`profile_id`),
  KEY `judge_blogpost_authors_profile_id_18d1d3e2_fk_judge_profile_id` (`profile_id`),
  CONSTRAINT `judge_blogpost_authors_blogpost_id_43745d7c_fk_judge_blogpost_id` FOREIGN KEY (`blogpost_id`) REFERENCES `judge_blogpost` (`id`),
  CONSTRAINT `judge_blogpost_authors_profile_id_18d1d3e2_fk_judge_profile_id` FOREIGN KEY (`profile_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_class`
--

DROP TABLE IF EXISTS `judge_class`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_class` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `slug` varchar(128) NOT NULL,
  `description` longtext NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `access_code` varchar(7) DEFAULT NULL,
  `organization_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `judge_class_organization_id_61de0a34_fk_judge_organization_id` (`organization_id`),
  KEY `judge_class_slug_17cf0657` (`slug`),
  CONSTRAINT `judge_class_organization_id_61de0a34_fk_judge_organization_id` FOREIGN KEY (`organization_id`) REFERENCES `judge_organization` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_class_admins`
--

DROP TABLE IF EXISTS `judge_class_admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_class_admins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `class_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_class_admins_class_id_profile_id_57d3c53c_uniq` (`class_id`,`profile_id`),
  KEY `judge_class_admins_profile_id_101db2a9_fk_judge_profile_id` (`profile_id`),
  CONSTRAINT `judge_class_admins_class_id_bfb8582e_fk_judge_class_id` FOREIGN KEY (`class_id`) REFERENCES `judge_class` (`id`),
  CONSTRAINT `judge_class_admins_profile_id_101db2a9_fk_judge_profile_id` FOREIGN KEY (`profile_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_class_members`
--

DROP TABLE IF EXISTS `judge_class_members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_class_members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `class_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_class_members_class_id_profile_id_49696836_uniq` (`class_id`,`profile_id`),
  KEY `judge_class_members_profile_id_e78dc0af_fk_judge_profile_id` (`profile_id`),
  CONSTRAINT `judge_class_members_class_id_b96416d5_fk_judge_class_id` FOREIGN KEY (`class_id`) REFERENCES `judge_class` (`id`),
  CONSTRAINT `judge_class_members_profile_id_e78dc0af_fk_judge_profile_id` FOREIGN KEY (`profile_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_comment`
--

DROP TABLE IF EXISTS `judge_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_comment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time` datetime(6) NOT NULL,
  `page` varchar(30) NOT NULL,
  `score` int(11) NOT NULL,
  `body` longtext NOT NULL,
  `hidden` tinyint(1) NOT NULL,
  `lft` int(10) unsigned NOT NULL CHECK (`lft` >= 0),
  `rght` int(10) unsigned NOT NULL CHECK (`rght` >= 0),
  `tree_id` int(10) unsigned NOT NULL CHECK (`tree_id` >= 0),
  `level` int(10) unsigned NOT NULL CHECK (`level` >= 0),
  `author_id` int(11) NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `revisions` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `judge_comment_author_id_ec3f8371_fk_judge_profile_id` (`author_id`),
  KEY `judge_comment_page_66eb6c11` (`page`),
  KEY `judge_comment_tree_id_cdde24bd` (`tree_id`),
  KEY `judge_comment_parent_id_e16fe797` (`parent_id`),
  CONSTRAINT `judge_comment_author_id_ec3f8371_fk_judge_profile_id` FOREIGN KEY (`author_id`) REFERENCES `judge_profile` (`id`),
  CONSTRAINT `judge_comment_parent_id_e16fe797_fk_judge_comment_id` FOREIGN KEY (`parent_id`) REFERENCES `judge_comment` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_commentlock`
--

DROP TABLE IF EXISTS `judge_commentlock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_commentlock` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `page` varchar(30) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `judge_commentlock_page_3aec2c30` (`page`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_commentvote`
--

DROP TABLE IF EXISTS `judge_commentvote`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_commentvote` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `score` int(11) NOT NULL,
  `comment_id` int(11) NOT NULL,
  `voter_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_commentvote_voter_id_comment_id_2fa9cd9b_uniq` (`voter_id`,`comment_id`),
  KEY `judge_commentvote_comment_id_9711d946_fk_judge_comment_id` (`comment_id`),
  CONSTRAINT `judge_commentvote_comment_id_9711d946_fk_judge_comment_id` FOREIGN KEY (`comment_id`) REFERENCES `judge_comment` (`id`),
  CONSTRAINT `judge_commentvote_voter_id_49326699_fk_judge_profile_id` FOREIGN KEY (`voter_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_contest`
--

DROP TABLE IF EXISTS `judge_contest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_contest` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` longtext NOT NULL,
  `start_time` datetime(6) NOT NULL,
  `end_time` datetime(6) NOT NULL,
  `time_limit` bigint(20) DEFAULT NULL,
  `is_visible` tinyint(1) NOT NULL,
  `is_rated` tinyint(1) NOT NULL,
  `use_clarifications` tinyint(1) NOT NULL,
  `rate_all` tinyint(1) NOT NULL,
  `is_private` tinyint(1) NOT NULL,
  `hide_problem_tags` tinyint(1) NOT NULL,
  `run_pretests_only` tinyint(1) NOT NULL,
  `og_image` varchar(150) NOT NULL,
  `logo_override_image` varchar(150) NOT NULL,
  `user_count` int(11) NOT NULL,
  `summary` longtext NOT NULL,
  `access_code` varchar(255) NOT NULL,
  `format_name` varchar(32) NOT NULL,
  `format_config` longtext DEFAULT NULL,
  `rating_ceiling` int(11) DEFAULT NULL,
  `rating_floor` int(11) DEFAULT NULL,
  `is_organization_private` tinyint(1) NOT NULL,
  `problem_label_script` longtext NOT NULL,
  `points_precision` int(11) NOT NULL,
  `scoreboard_visibility` varchar(1) NOT NULL,
  `locked_after` datetime(6) DEFAULT NULL,
  `hide_problem_authors` tinyint(1) NOT NULL,
  `show_short_display` tinyint(1) NOT NULL,
  `tester_see_scoreboard` tinyint(1) NOT NULL,
  `limit_join_organizations` tinyint(1) NOT NULL,
  `tester_see_submissions` tinyint(1) NOT NULL,
  `performance_ceiling_override` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `key` (`key`),
  KEY `judge_contest_name_23b5c29c` (`name`),
  KEY `judge_contest_start_time_8dd80870` (`start_time`),
  KEY `judge_contest_end_time_f0179778` (`end_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_contest_authors`
--

DROP TABLE IF EXISTS `judge_contest_authors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_contest_authors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contest_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_contest_organizers_contest_id_profile_id_35f37708_uniq` (`contest_id`,`profile_id`),
  KEY `judge_contest_organizers_profile_id_fe54f029_fk_judge_profile_id` (`profile_id`),
  CONSTRAINT `judge_contest_organizers_contest_id_266a7461_fk_judge_contest_id` FOREIGN KEY (`contest_id`) REFERENCES `judge_contest` (`id`),
  CONSTRAINT `judge_contest_organizers_profile_id_fe54f029_fk_judge_profile_id` FOREIGN KEY (`profile_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_contest_banned_users`
--

DROP TABLE IF EXISTS `judge_contest_banned_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_contest_banned_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contest_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_contest_banned_users_contest_id_profile_id_b0570b33_uniq` (`contest_id`,`profile_id`),
  KEY `judge_contest_banned_profile_id_ae615b59_fk_judge_pro` (`profile_id`),
  CONSTRAINT `judge_contest_banned_contest_id_14d2192a_fk_judge_con` FOREIGN KEY (`contest_id`) REFERENCES `judge_contest` (`id`),
  CONSTRAINT `judge_contest_banned_profile_id_ae615b59_fk_judge_pro` FOREIGN KEY (`profile_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_contest_classes`
--

DROP TABLE IF EXISTS `judge_contest_classes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_contest_classes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contest_id` int(11) NOT NULL,
  `class_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_contest_classes_contest_id_class_id_68b80e19_uniq` (`contest_id`,`class_id`),
  KEY `judge_contest_classes_class_id_ec8aa197_fk_judge_class_id` (`class_id`),
  CONSTRAINT `judge_contest_classes_class_id_ec8aa197_fk_judge_class_id` FOREIGN KEY (`class_id`) REFERENCES `judge_class` (`id`),
  CONSTRAINT `judge_contest_classes_contest_id_23496dec_fk_judge_contest_id` FOREIGN KEY (`contest_id`) REFERENCES `judge_contest` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_contest_curators`
--

DROP TABLE IF EXISTS `judge_contest_curators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_contest_curators` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contest_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_contest_curators_contest_id_profile_id_6bcc5bc0_uniq` (`contest_id`,`profile_id`),
  KEY `judge_contest_curators_profile_id_73c4ada2_fk_judge_profile_id` (`profile_id`),
  CONSTRAINT `judge_contest_curators_contest_id_06a850b7_fk_judge_contest_id` FOREIGN KEY (`contest_id`) REFERENCES `judge_contest` (`id`),
  CONSTRAINT `judge_contest_curators_profile_id_73c4ada2_fk_judge_profile_id` FOREIGN KEY (`profile_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_contest_join_organizations`
--

DROP TABLE IF EXISTS `judge_contest_join_organizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_contest_join_organizations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contest_id` int(11) NOT NULL,
  `organization_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_contest_join_organ_contest_id_organization__0ec22fca_uniq` (`contest_id`,`organization_id`),
  KEY `judge_contest_join_o_organization_id_3a85e2ca_fk_judge_org` (`organization_id`),
  CONSTRAINT `judge_contest_join_o_contest_id_af9687f0_fk_judge_con` FOREIGN KEY (`contest_id`) REFERENCES `judge_contest` (`id`),
  CONSTRAINT `judge_contest_join_o_organization_id_3a85e2ca_fk_judge_org` FOREIGN KEY (`organization_id`) REFERENCES `judge_organization` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_contest_organizations`
--

DROP TABLE IF EXISTS `judge_contest_organizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_contest_organizations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contest_id` int(11) NOT NULL,
  `organization_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_contest_organizati_contest_id_organization__f8aafa91_uniq` (`contest_id`,`organization_id`),
  KEY `judge_contest_organi_organization_id_6ccef0d9_fk_judge_org` (`organization_id`),
  CONSTRAINT `judge_contest_organi_contest_id_8b6686ce_fk_judge_con` FOREIGN KEY (`contest_id`) REFERENCES `judge_contest` (`id`),
  CONSTRAINT `judge_contest_organi_organization_id_6ccef0d9_fk_judge_org` FOREIGN KEY (`organization_id`) REFERENCES `judge_organization` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_contest_private_contestants`
--

DROP TABLE IF EXISTS `judge_contest_private_contestants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_contest_private_contestants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contest_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_contest_private_co_contest_id_profile_id_ef23dc8d_uniq` (`contest_id`,`profile_id`),
  KEY `judge_contest_privat_profile_id_34a11bc5_fk_judge_pro` (`profile_id`),
  CONSTRAINT `judge_contest_privat_contest_id_a30921fe_fk_judge_con` FOREIGN KEY (`contest_id`) REFERENCES `judge_contest` (`id`),
  CONSTRAINT `judge_contest_privat_profile_id_34a11bc5_fk_judge_pro` FOREIGN KEY (`profile_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_contest_rate_exclude`
--

DROP TABLE IF EXISTS `judge_contest_rate_exclude`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_contest_rate_exclude` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contest_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_contest_rate_exclude_contest_id_profile_id_2b34d7a9_uniq` (`contest_id`,`profile_id`),
  KEY `judge_contest_rate_e_profile_id_6c9400fa_fk_judge_pro` (`profile_id`),
  CONSTRAINT `judge_contest_rate_e_contest_id_30174232_fk_judge_con` FOREIGN KEY (`contest_id`) REFERENCES `judge_contest` (`id`),
  CONSTRAINT `judge_contest_rate_e_profile_id_6c9400fa_fk_judge_pro` FOREIGN KEY (`profile_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_contest_spectators`
--

DROP TABLE IF EXISTS `judge_contest_spectators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_contest_spectators` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contest_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_contest_spectators_contest_id_profile_id_681c4e60_uniq` (`contest_id`,`profile_id`),
  KEY `judge_contest_spectators_profile_id_bbe7dd96_fk_judge_profile_id` (`profile_id`),
  CONSTRAINT `judge_contest_spectators_contest_id_1bee62ed_fk_judge_contest_id` FOREIGN KEY (`contest_id`) REFERENCES `judge_contest` (`id`),
  CONSTRAINT `judge_contest_spectators_profile_id_bbe7dd96_fk_judge_profile_id` FOREIGN KEY (`profile_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_contest_tags`
--

DROP TABLE IF EXISTS `judge_contest_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_contest_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contest_id` int(11) NOT NULL,
  `contesttag_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_contest_tags_contest_id_contesttag_id_eedb695b_uniq` (`contest_id`,`contesttag_id`),
  KEY `judge_contest_tags_contesttag_id_5d9788bd_fk_judge_contesttag_id` (`contesttag_id`),
  CONSTRAINT `judge_contest_tags_contest_id_998f99f7_fk_judge_contest_id` FOREIGN KEY (`contest_id`) REFERENCES `judge_contest` (`id`),
  CONSTRAINT `judge_contest_tags_contesttag_id_5d9788bd_fk_judge_contesttag_id` FOREIGN KEY (`contesttag_id`) REFERENCES `judge_contesttag` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_contest_testers`
--

DROP TABLE IF EXISTS `judge_contest_testers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_contest_testers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contest_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_contest_testers_contest_id_profile_id_52e96be5_uniq` (`contest_id`,`profile_id`),
  KEY `judge_contest_testers_profile_id_d62d1c9b_fk_judge_profile_id` (`profile_id`),
  CONSTRAINT `judge_contest_testers_contest_id_6122faf2_fk_judge_contest_id` FOREIGN KEY (`contest_id`) REFERENCES `judge_contest` (`id`),
  CONSTRAINT `judge_contest_testers_profile_id_d62d1c9b_fk_judge_profile_id` FOREIGN KEY (`profile_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_contest_view_contest_scoreboard`
--

DROP TABLE IF EXISTS `judge_contest_view_contest_scoreboard`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_contest_view_contest_scoreboard` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contest_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_contest_view_conte_contest_id_profile_id_5fbd08d1_uniq` (`contest_id`,`profile_id`),
  KEY `judge_contest_view_c_profile_id_60bb0f4a_fk_judge_pro` (`profile_id`),
  CONSTRAINT `judge_contest_view_c_contest_id_30aa03fe_fk_judge_con` FOREIGN KEY (`contest_id`) REFERENCES `judge_contest` (`id`),
  CONSTRAINT `judge_contest_view_c_profile_id_60bb0f4a_fk_judge_pro` FOREIGN KEY (`profile_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_contest_view_contest_submissions`
--

DROP TABLE IF EXISTS `judge_contest_view_contest_submissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_contest_view_contest_submissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contest_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_contest_view_conte_contest_id_profile_id_129488b6_uniq` (`contest_id`,`profile_id`),
  KEY `judge_contest_view_c_profile_id_7d10b3c7_fk_judge_pro` (`profile_id`),
  CONSTRAINT `judge_contest_view_c_contest_id_d5c1c6cb_fk_judge_con` FOREIGN KEY (`contest_id`) REFERENCES `judge_contest` (`id`),
  CONSTRAINT `judge_contest_view_c_profile_id_7d10b3c7_fk_judge_pro` FOREIGN KEY (`profile_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_contestmoss`
--

DROP TABLE IF EXISTS `judge_contestmoss`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_contestmoss` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `language` varchar(10) NOT NULL,
  `submission_count` int(10) unsigned NOT NULL CHECK (`submission_count` >= 0),
  `url` varchar(200) DEFAULT NULL,
  `contest_id` int(11) NOT NULL,
  `problem_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_contestmoss_contest_id_problem_id_language_52b59ba8_uniq` (`contest_id`,`problem_id`,`language`),
  KEY `judge_contestmoss_problem_id_5d8c1e4e_fk_judge_problem_id` (`problem_id`),
  CONSTRAINT `judge_contestmoss_contest_id_24908198_fk_judge_contest_id` FOREIGN KEY (`contest_id`) REFERENCES `judge_contest` (`id`),
  CONSTRAINT `judge_contestmoss_problem_id_5d8c1e4e_fk_judge_problem_id` FOREIGN KEY (`problem_id`) REFERENCES `judge_problem` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_contestparticipation`
--

DROP TABLE IF EXISTS `judge_contestparticipation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_contestparticipation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start` datetime(6) NOT NULL,
  `score` double NOT NULL,
  `cumtime` int(10) unsigned NOT NULL CHECK (`cumtime` >= 0),
  `virtual` int(11) NOT NULL,
  `format_data` longtext DEFAULT NULL,
  `contest_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `is_disqualified` tinyint(1) NOT NULL,
  `tiebreaker` double NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_contestparticipati_contest_id_user_id_virtu_dc257b0c_uniq` (`contest_id`,`user_id`,`virtual`),
  KEY `judge_contestparticipation_user_id_5896ee2e_fk_judge_profile_id` (`user_id`),
  KEY `judge_contestparticipation_score_4098b84f` (`score`),
  CONSTRAINT `judge_contestpartici_contest_id_ab097823_fk_judge_con` FOREIGN KEY (`contest_id`) REFERENCES `judge_contest` (`id`),
  CONSTRAINT `judge_contestparticipation_user_id_5896ee2e_fk_judge_profile_id` FOREIGN KEY (`user_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_contestproblem`
--

DROP TABLE IF EXISTS `judge_contestproblem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_contestproblem` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `points` int(11) NOT NULL,
  `partial` tinyint(1) NOT NULL,
  `is_pretested` tinyint(1) NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  `output_prefix_override` int(11) DEFAULT NULL,
  `max_submissions` int(11) DEFAULT NULL,
  `contest_id` int(11) NOT NULL,
  `problem_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_contestproblem_problem_id_contest_id_4ae77fe0_uniq` (`problem_id`,`contest_id`),
  KEY `judge_contestproblem_contest_id_b28b7107_fk_judge_contest_id` (`contest_id`),
  KEY `judge_contestproblem_order_05ce0638` (`order`),
  CONSTRAINT `judge_contestproblem_contest_id_b28b7107_fk_judge_contest_id` FOREIGN KEY (`contest_id`) REFERENCES `judge_contest` (`id`),
  CONSTRAINT `judge_contestproblem_problem_id_fc63c700_fk_judge_problem_id` FOREIGN KEY (`problem_id`) REFERENCES `judge_problem` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_contestsubmission`
--

DROP TABLE IF EXISTS `judge_contestsubmission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_contestsubmission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `points` double NOT NULL,
  `is_pretest` tinyint(1) NOT NULL,
  `participation_id` int(11) NOT NULL,
  `problem_id` int(11) NOT NULL,
  `submission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `submission_id` (`submission_id`),
  KEY `judge_contestsubmiss_participation_id_cf83bbb0_fk_judge_con` (`participation_id`),
  KEY `judge_contestsubmiss_problem_id_1b1240d4_fk_judge_con` (`problem_id`),
  CONSTRAINT `judge_contestsubmiss_participation_id_cf83bbb0_fk_judge_con` FOREIGN KEY (`participation_id`) REFERENCES `judge_contestparticipation` (`id`),
  CONSTRAINT `judge_contestsubmiss_problem_id_1b1240d4_fk_judge_con` FOREIGN KEY (`problem_id`) REFERENCES `judge_contestproblem` (`id`),
  CONSTRAINT `judge_contestsubmiss_submission_id_1384e5aa_fk_judge_sub` FOREIGN KEY (`submission_id`) REFERENCES `judge_submission` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_contesttag`
--

DROP TABLE IF EXISTS `judge_contesttag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_contesttag` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `color` varchar(7) NOT NULL,
  `description` longtext NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_judge`
--

DROP TABLE IF EXISTS `judge_judge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_judge` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `created` datetime(6) NOT NULL,
  `auth_key` varchar(100) NOT NULL,
  `is_blocked` tinyint(1) NOT NULL,
  `online` tinyint(1) NOT NULL,
  `start_time` datetime(6) DEFAULT NULL,
  `ping` double DEFAULT NULL,
  `load` double DEFAULT NULL,
  `description` longtext NOT NULL,
  `last_ip` char(39) DEFAULT NULL,
  `is_disabled` tinyint(1) NOT NULL,
  `tier` int(10) unsigned NOT NULL CHECK (`tier` >= 0),
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_judge_problems`
--

DROP TABLE IF EXISTS `judge_judge_problems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_judge_problems` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `judge_id` int(11) NOT NULL,
  `problem_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_judge_problems_judge_id_problem_id_7cc4b18b_uniq` (`judge_id`,`problem_id`),
  KEY `judge_judge_problems_problem_id_fa0f569c_fk_judge_problem_id` (`problem_id`),
  CONSTRAINT `judge_judge_problems_judge_id_e0c28fa3_fk_judge_judge_id` FOREIGN KEY (`judge_id`) REFERENCES `judge_judge` (`id`),
  CONSTRAINT `judge_judge_problems_problem_id_fa0f569c_fk_judge_problem_id` FOREIGN KEY (`problem_id`) REFERENCES `judge_problem` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_judge_runtimes`
--

DROP TABLE IF EXISTS `judge_judge_runtimes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_judge_runtimes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `judge_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_judge_runtimes_judge_id_language_id_ececbd6e_uniq` (`judge_id`,`language_id`),
  KEY `judge_judge_runtimes_language_id_9575fc7b_fk_judge_language_id` (`language_id`),
  CONSTRAINT `judge_judge_runtimes_judge_id_770ad6a5_fk_judge_judge_id` FOREIGN KEY (`judge_id`) REFERENCES `judge_judge` (`id`),
  CONSTRAINT `judge_judge_runtimes_language_id_9575fc7b_fk_judge_language_id` FOREIGN KEY (`language_id`) REFERENCES `judge_language` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_language`
--

DROP TABLE IF EXISTS `judge_language`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_language` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(6) NOT NULL,
  `name` varchar(20) NOT NULL,
  `short_name` varchar(10) DEFAULT NULL,
  `common_name` varchar(10) NOT NULL,
  `ace` varchar(20) NOT NULL,
  `pygments` varchar(20) NOT NULL,
  `template` longtext NOT NULL,
  `info` varchar(50) NOT NULL,
  `description` longtext NOT NULL,
  `extension` varchar(10) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_languagelimit`
--

DROP TABLE IF EXISTS `judge_languagelimit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_languagelimit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time_limit` double NOT NULL,
  `memory_limit` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `problem_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_languagelimit_problem_id_language_id_fbd3d3fc_uniq` (`problem_id`,`language_id`),
  KEY `judge_languagelimit_language_id_b81fe043_fk_judge_language_id` (`language_id`),
  CONSTRAINT `judge_languagelimit_language_id_b81fe043_fk_judge_language_id` FOREIGN KEY (`language_id`) REFERENCES `judge_language` (`id`),
  CONSTRAINT `judge_languagelimit_problem_id_bb544679_fk_judge_problem_id` FOREIGN KEY (`problem_id`) REFERENCES `judge_problem` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_license`
--

DROP TABLE IF EXISTS `judge_license`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_license` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(20) NOT NULL,
  `link` varchar(256) NOT NULL,
  `name` varchar(256) NOT NULL,
  `display` varchar(256) NOT NULL,
  `icon` varchar(256) NOT NULL,
  `text` longtext NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_miscconfig`
--

DROP TABLE IF EXISTS `judge_miscconfig`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_miscconfig` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(30) NOT NULL,
  `value` longtext NOT NULL,
  PRIMARY KEY (`id`),
  KEY `judge_miscconfig_key_bb230360` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_navigationbar`
--

DROP TABLE IF EXISTS `judge_navigationbar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_navigationbar` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  `key` varchar(10) NOT NULL,
  `label` varchar(20) NOT NULL,
  `path` varchar(255) NOT NULL,
  `regex` longtext NOT NULL,
  `lft` int(10) unsigned NOT NULL CHECK (`lft` >= 0),
  `rght` int(10) unsigned NOT NULL CHECK (`rght` >= 0),
  `tree_id` int(10) unsigned NOT NULL CHECK (`tree_id` >= 0),
  `level` int(10) unsigned NOT NULL CHECK (`level` >= 0),
  `parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `key` (`key`),
  KEY `judge_navigationbar_order_48c84306` (`order`),
  KEY `judge_navigationbar_tree_id_e12b3b53` (`tree_id`),
  KEY `judge_navigationbar_parent_id_806f64e3` (`parent_id`),
  CONSTRAINT `judge_navigationbar_parent_id_806f64e3_fk_judge_navigationbar_id` FOREIGN KEY (`parent_id`) REFERENCES `judge_navigationbar` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_organization`
--

DROP TABLE IF EXISTS `judge_organization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_organization` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `slug` varchar(128) NOT NULL,
  `short_name` varchar(20) NOT NULL,
  `about` longtext NOT NULL,
  `creation_date` datetime(6) NOT NULL,
  `is_open` tinyint(1) NOT NULL,
  `slots` int(11) DEFAULT NULL,
  `access_code` varchar(7) DEFAULT NULL,
  `logo_override_image` varchar(150) NOT NULL,
  `class_required` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `judge_organization_slug_5e7161c5` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_organization_admins`
--

DROP TABLE IF EXISTS `judge_organization_admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_organization_admins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_organization_admin_organization_id_profile__7528cebe_uniq` (`organization_id`,`profile_id`),
  KEY `judge_organization_a_profile_id_b5559f11_fk_judge_pro` (`profile_id`),
  CONSTRAINT `judge_organization_a_organization_id_b2125a57_fk_judge_org` FOREIGN KEY (`organization_id`) REFERENCES `judge_organization` (`id`),
  CONSTRAINT `judge_organization_a_profile_id_b5559f11_fk_judge_pro` FOREIGN KEY (`profile_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_organizationrequest`
--

DROP TABLE IF EXISTS `judge_organizationrequest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_organizationrequest` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time` datetime(6) NOT NULL,
  `state` varchar(1) NOT NULL,
  `reason` longtext NOT NULL,
  `organization_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `request_class_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `judge_organizationrequest_user_id_b721da81_fk_judge_profile_id` (`user_id`),
  KEY `judge_organizationre_organization_id_e2ab3e9a_fk_judge_org` (`organization_id`),
  KEY `judge_organizationre_request_class_id_e58835fe_fk_judge_cla` (`request_class_id`),
  CONSTRAINT `judge_organizationre_organization_id_e2ab3e9a_fk_judge_org` FOREIGN KEY (`organization_id`) REFERENCES `judge_organization` (`id`),
  CONSTRAINT `judge_organizationre_request_class_id_e58835fe_fk_judge_cla` FOREIGN KEY (`request_class_id`) REFERENCES `judge_class` (`id`),
  CONSTRAINT `judge_organizationrequest_user_id_b721da81_fk_judge_profile_id` FOREIGN KEY (`user_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_problem`
--

DROP TABLE IF EXISTS `judge_problem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_problem` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` longtext NOT NULL,
  `time_limit` double NOT NULL,
  `memory_limit` int(10) unsigned NOT NULL,
  `short_circuit` tinyint(1) NOT NULL,
  `points` double NOT NULL,
  `partial` tinyint(1) NOT NULL,
  `is_public` tinyint(1) NOT NULL,
  `is_manually_managed` tinyint(1) NOT NULL,
  `date` datetime(6) DEFAULT NULL,
  `og_image` varchar(150) NOT NULL,
  `summary` longtext NOT NULL,
  `user_count` int(11) NOT NULL,
  `ac_rate` double NOT NULL,
  `is_organization_private` tinyint(1) NOT NULL,
  `group_id` int(11) NOT NULL,
  `license_id` int(11) DEFAULT NULL,
  `is_full_markup` tinyint(1) NOT NULL,
  `submission_source_visibility_mode` varchar(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `judge_problem_group_id_1b7ca650_fk_judge_problemgroup_id` (`group_id`),
  KEY `judge_problem_license_id_32ca8b1a_fk_judge_license_id` (`license_id`),
  KEY `judge_problem_name_c48e19b2` (`name`),
  KEY `judge_problem_is_public_c5da02a8` (`is_public`),
  KEY `judge_problem_is_manually_managed_56d3b634` (`is_manually_managed`),
  KEY `judge_problem_date_f1f729a4` (`date`),
  CONSTRAINT `judge_problem_group_id_1b7ca650_fk_judge_problemgroup_id` FOREIGN KEY (`group_id`) REFERENCES `judge_problemgroup` (`id`),
  CONSTRAINT `judge_problem_license_id_32ca8b1a_fk_judge_license_id` FOREIGN KEY (`license_id`) REFERENCES `judge_license` (`id`),
  CONSTRAINT `judge_problem_memory_limit_a129f739_check` CHECK (`memory_limit` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_problem_allowed_languages`
--

DROP TABLE IF EXISTS `judge_problem_allowed_languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_problem_allowed_languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `problem_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_problem_allowed_la_problem_id_language_id_f6265ceb_uniq` (`problem_id`,`language_id`),
  KEY `judge_problem_allowe_language_id_67ad291b_fk_judge_lan` (`language_id`),
  CONSTRAINT `judge_problem_allowe_language_id_67ad291b_fk_judge_lan` FOREIGN KEY (`language_id`) REFERENCES `judge_language` (`id`),
  CONSTRAINT `judge_problem_allowe_problem_id_1020494d_fk_judge_pro` FOREIGN KEY (`problem_id`) REFERENCES `judge_problem` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_problem_authors`
--

DROP TABLE IF EXISTS `judge_problem_authors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_problem_authors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `problem_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_problem_authors_problem_id_profile_id_4c5741b5_uniq` (`problem_id`,`profile_id`),
  KEY `judge_problem_authors_profile_id_e9577295_fk_judge_profile_id` (`profile_id`),
  CONSTRAINT `judge_problem_authors_problem_id_e7c69267_fk_judge_problem_id` FOREIGN KEY (`problem_id`) REFERENCES `judge_problem` (`id`),
  CONSTRAINT `judge_problem_authors_profile_id_e9577295_fk_judge_profile_id` FOREIGN KEY (`profile_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_problem_banned_users`
--

DROP TABLE IF EXISTS `judge_problem_banned_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_problem_banned_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `problem_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_problem_banned_users_problem_id_profile_id_068a01f9_uniq` (`problem_id`,`profile_id`),
  KEY `judge_problem_banned_profile_id_4dcfff77_fk_judge_pro` (`profile_id`),
  CONSTRAINT `judge_problem_banned_problem_id_f5f73ac2_fk_judge_pro` FOREIGN KEY (`problem_id`) REFERENCES `judge_problem` (`id`),
  CONSTRAINT `judge_problem_banned_profile_id_4dcfff77_fk_judge_pro` FOREIGN KEY (`profile_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_problem_curators`
--

DROP TABLE IF EXISTS `judge_problem_curators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_problem_curators` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `problem_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_problem_curators_problem_id_profile_id_daffe335_uniq` (`problem_id`,`profile_id`),
  KEY `judge_problem_curators_profile_id_46e87efb_fk_judge_profile_id` (`profile_id`),
  CONSTRAINT `judge_problem_curators_problem_id_6babca8c_fk_judge_problem_id` FOREIGN KEY (`problem_id`) REFERENCES `judge_problem` (`id`),
  CONSTRAINT `judge_problem_curators_profile_id_46e87efb_fk_judge_profile_id` FOREIGN KEY (`profile_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_problem_organizations`
--

DROP TABLE IF EXISTS `judge_problem_organizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_problem_organizations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `problem_id` int(11) NOT NULL,
  `organization_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_problem_organizati_problem_id_organization__2745924c_uniq` (`problem_id`,`organization_id`),
  KEY `judge_problem_organi_organization_id_0eb88735_fk_judge_org` (`organization_id`),
  CONSTRAINT `judge_problem_organi_organization_id_0eb88735_fk_judge_org` FOREIGN KEY (`organization_id`) REFERENCES `judge_organization` (`id`),
  CONSTRAINT `judge_problem_organi_problem_id_d3edc28b_fk_judge_pro` FOREIGN KEY (`problem_id`) REFERENCES `judge_problem` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_problem_testers`
--

DROP TABLE IF EXISTS `judge_problem_testers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_problem_testers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `problem_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_problem_testers_problem_id_profile_id_3ff28b2a_uniq` (`problem_id`,`profile_id`),
  KEY `judge_problem_testers_profile_id_dadcfbad_fk_judge_profile_id` (`profile_id`),
  CONSTRAINT `judge_problem_testers_problem_id_0796300b_fk_judge_problem_id` FOREIGN KEY (`problem_id`) REFERENCES `judge_problem` (`id`),
  CONSTRAINT `judge_problem_testers_profile_id_dadcfbad_fk_judge_profile_id` FOREIGN KEY (`profile_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_problem_types`
--

DROP TABLE IF EXISTS `judge_problem_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_problem_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `problem_id` int(11) NOT NULL,
  `problemtype_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_problem_types_problem_id_problemtype_id_db67c44c_uniq` (`problem_id`,`problemtype_id`),
  KEY `judge_problem_types_problemtype_id_f51f1eea_fk_judge_pro` (`problemtype_id`),
  CONSTRAINT `judge_problem_types_problem_id_1c63e65f_fk_judge_problem_id` FOREIGN KEY (`problem_id`) REFERENCES `judge_problem` (`id`),
  CONSTRAINT `judge_problem_types_problemtype_id_f51f1eea_fk_judge_pro` FOREIGN KEY (`problemtype_id`) REFERENCES `judge_problemtype` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_problemclarification`
--

DROP TABLE IF EXISTS `judge_problemclarification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_problemclarification` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` longtext NOT NULL,
  `date` datetime(6) NOT NULL,
  `problem_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `judge_problemclarifi_problem_id_3d9eb049_fk_judge_pro` (`problem_id`),
  CONSTRAINT `judge_problemclarifi_problem_id_3d9eb049_fk_judge_pro` FOREIGN KEY (`problem_id`) REFERENCES `judge_problem` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_problemdata`
--

DROP TABLE IF EXISTS `judge_problemdata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_problemdata` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `zipfile` varchar(100) DEFAULT NULL,
  `generator` varchar(100) DEFAULT NULL,
  `output_prefix` int(11) DEFAULT NULL,
  `output_limit` int(11) DEFAULT NULL,
  `feedback` longtext NOT NULL,
  `checker` varchar(10) NOT NULL,
  `checker_args` longtext NOT NULL,
  `problem_id` int(11) NOT NULL,
  `nobigmath` tinyint(1) DEFAULT NULL,
  `unicode` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `problem_id` (`problem_id`),
  CONSTRAINT `judge_problemdata_problem_id_d825e6f8_fk_judge_problem_id` FOREIGN KEY (`problem_id`) REFERENCES `judge_problem` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_problemgroup`
--

DROP TABLE IF EXISTS `judge_problemgroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_problemgroup` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_problempointsvote`
--

DROP TABLE IF EXISTS `judge_problempointsvote`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_problempointsvote` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `points` int(11) NOT NULL,
  `note` longtext NOT NULL,
  `problem_id` int(11) NOT NULL,
  `voter_id` int(11) NOT NULL,
  `vote_time` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `judge_problempointsvote_problem_id_ae3ad4d5_fk_judge_problem_id` (`problem_id`),
  KEY `judge_problempointsvote_voter_id_79027a88_fk_judge_profile_id` (`voter_id`),
  CONSTRAINT `judge_problempointsvote_problem_id_ae3ad4d5_fk_judge_problem_id` FOREIGN KEY (`problem_id`) REFERENCES `judge_problem` (`id`),
  CONSTRAINT `judge_problempointsvote_voter_id_79027a88_fk_judge_profile_id` FOREIGN KEY (`voter_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_problemtestcase`
--

DROP TABLE IF EXISTS `judge_problemtestcase`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_problemtestcase` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order` int(11) NOT NULL,
  `type` varchar(1) NOT NULL,
  `input_file` varchar(100) NOT NULL,
  `output_file` varchar(100) NOT NULL,
  `generator_args` longtext NOT NULL,
  `points` int(11) DEFAULT NULL,
  `is_pretest` tinyint(1) NOT NULL,
  `output_prefix` int(11) DEFAULT NULL,
  `output_limit` int(11) DEFAULT NULL,
  `checker` varchar(10) NOT NULL,
  `checker_args` longtext NOT NULL,
  `dataset_id` int(11) NOT NULL,
  `batch_dependencies` longtext NOT NULL,
  PRIMARY KEY (`id`),
  KEY `judge_problemtestcase_dataset_id_964229fd_fk_judge_problem_id` (`dataset_id`),
  CONSTRAINT `judge_problemtestcase_dataset_id_964229fd_fk_judge_problem_id` FOREIGN KEY (`dataset_id`) REFERENCES `judge_problem` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_problemtranslation`
--

DROP TABLE IF EXISTS `judge_problemtranslation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_problemtranslation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `language` varchar(7) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` longtext NOT NULL,
  `problem_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_problemtranslation_problem_id_language_ed6ab873_uniq` (`problem_id`,`language`),
  KEY `judge_problemtranslation_name_3bfcdd8c` (`name`),
  CONSTRAINT `judge_problemtranslation_problem_id_7acb27a7_fk_judge_problem_id` FOREIGN KEY (`problem_id`) REFERENCES `judge_problem` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_problemtype`
--

DROP TABLE IF EXISTS `judge_problemtype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_problemtype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_profile`
--

DROP TABLE IF EXISTS `judge_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_profile` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `about` longtext DEFAULT NULL,
  `timezone` varchar(50) NOT NULL,
  `points` double NOT NULL,
  `performance_points` double NOT NULL,
  `problem_count` int(11) NOT NULL,
  `ace_theme` varchar(30) NOT NULL,
  `last_access` datetime(6) NOT NULL,
  `ip` char(39) DEFAULT NULL,
  `display_rank` varchar(10) NOT NULL,
  `mute` tinyint(1) NOT NULL,
  `is_unlisted` tinyint(1) NOT NULL,
  `rating` int(11) DEFAULT NULL,
  `user_script` longtext NOT NULL,
  `math_engine` varchar(4) NOT NULL,
  `is_totp_enabled` tinyint(1) NOT NULL,
  `totp_key` longblob DEFAULT NULL,
  `notes` longtext DEFAULT NULL,
  `current_contest_id` int(11) DEFAULT NULL,
  `language_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `api_token` varchar(64) DEFAULT NULL,
  `is_webauthn_enabled` tinyint(1) NOT NULL,
  `data_last_downloaded` datetime(6) DEFAULT NULL,
  `scratch_codes` longblob DEFAULT NULL,
  `last_totp_timecode` int(11) NOT NULL,
  `username_display_override` varchar(100) NOT NULL,
  `is_banned_from_problem_voting` tinyint(1) NOT NULL,
  `site_theme` varchar(10) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `current_contest_id` (`current_contest_id`),
  KEY `judge_profile_language_id_87d3cab1_fk_judge_language_id` (`language_id`),
  KEY `judge_profi_is_unli_1410d8_idx` (`is_unlisted`,`performance_points` DESC),
  KEY `judge_profi_is_unli_bcf16a_idx` (`is_unlisted`,`rating` DESC),
  KEY `judge_profi_is_unli_171bf3_idx` (`is_unlisted`,`problem_count` DESC),
  CONSTRAINT `judge_profile_current_contest_id_ca595142_fk_judge_con` FOREIGN KEY (`current_contest_id`) REFERENCES `judge_contestparticipation` (`id`),
  CONSTRAINT `judge_profile_language_id_87d3cab1_fk_judge_language_id` FOREIGN KEY (`language_id`) REFERENCES `judge_language` (`id`),
  CONSTRAINT `judge_profile_user_id_b62d6977_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_profile_organizations`
--

DROP TABLE IF EXISTS `judge_profile_organizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_profile_organizations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sort_value` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  `organization_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_profile_organizati_profile_id_organization__39a6d8b0_uniq` (`profile_id`,`organization_id`),
  KEY `judge_profile_organi_organization_id_da2a4d7d_fk_judge_org` (`organization_id`),
  CONSTRAINT `judge_profile_organi_organization_id_da2a4d7d_fk_judge_org` FOREIGN KEY (`organization_id`) REFERENCES `judge_organization` (`id`),
  CONSTRAINT `judge_profile_organi_profile_id_6b79e464_fk_judge_pro` FOREIGN KEY (`profile_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_rating`
--

DROP TABLE IF EXISTS `judge_rating`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_rating` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rank` int(11) NOT NULL,
  `rating` int(11) NOT NULL,
  `last_rated` datetime(6) NOT NULL,
  `contest_id` int(11) NOT NULL,
  `participation_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `mean` double NOT NULL,
  `performance` double NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `participation_id` (`participation_id`),
  UNIQUE KEY `judge_rating_user_id_contest_id_461d7897_uniq` (`user_id`,`contest_id`),
  KEY `judge_rating_contest_id_0e97ae8c_fk_judge_contest_id` (`contest_id`),
  KEY `judge_rating_last_rated_65ff05f9` (`last_rated`),
  CONSTRAINT `judge_rating_contest_id_0e97ae8c_fk_judge_contest_id` FOREIGN KEY (`contest_id`) REFERENCES `judge_contest` (`id`),
  CONSTRAINT `judge_rating_participation_id_c8cf9d76_fk_judge_con` FOREIGN KEY (`participation_id`) REFERENCES `judge_contestparticipation` (`id`),
  CONSTRAINT `judge_rating_user_id_82072996_fk_judge_profile_id` FOREIGN KEY (`user_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_runtimeversion`
--

DROP TABLE IF EXISTS `judge_runtimeversion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_runtimeversion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `version` varchar(64) NOT NULL,
  `priority` int(11) NOT NULL,
  `judge_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `judge_runtimeversion_judge_id_96482e9d_fk_judge_judge_id` (`judge_id`),
  KEY `judge_runtimeversion_language_id_3ad8be59_fk_judge_language_id` (`language_id`),
  CONSTRAINT `judge_runtimeversion_judge_id_96482e9d_fk_judge_judge_id` FOREIGN KEY (`judge_id`) REFERENCES `judge_judge` (`id`),
  CONSTRAINT `judge_runtimeversion_language_id_3ad8be59_fk_judge_language_id` FOREIGN KEY (`language_id`) REFERENCES `judge_language` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_solution`
--

DROP TABLE IF EXISTS `judge_solution`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_solution` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `is_public` tinyint(1) NOT NULL,
  `publish_on` datetime(6) NOT NULL,
  `content` longtext NOT NULL,
  `problem_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `problem_id` (`problem_id`),
  CONSTRAINT `judge_solution_problem_id_44bbf556_fk_judge_problem_id` FOREIGN KEY (`problem_id`) REFERENCES `judge_problem` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_solution_authors`
--

DROP TABLE IF EXISTS `judge_solution_authors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_solution_authors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `solution_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_solution_authors_solution_id_profile_id_e45470e0_uniq` (`solution_id`,`profile_id`),
  KEY `judge_solution_authors_profile_id_685bd965_fk_judge_profile_id` (`profile_id`),
  CONSTRAINT `judge_solution_authors_profile_id_685bd965_fk_judge_profile_id` FOREIGN KEY (`profile_id`) REFERENCES `judge_profile` (`id`),
  CONSTRAINT `judge_solution_authors_solution_id_eab0d5e6_fk_judge_solution_id` FOREIGN KEY (`solution_id`) REFERENCES `judge_solution` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_submission`
--

DROP TABLE IF EXISTS `judge_submission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_submission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime(6) NOT NULL,
  `time` double DEFAULT NULL,
  `memory` double DEFAULT NULL,
  `points` double DEFAULT NULL,
  `status` varchar(2) NOT NULL,
  `result` varchar(3) DEFAULT NULL,
  `error` longtext DEFAULT NULL,
  `current_testcase` int(11) NOT NULL,
  `batch` tinyint(1) NOT NULL,
  `case_points` double NOT NULL,
  `case_total` double NOT NULL,
  `is_pretested` tinyint(1) NOT NULL,
  `judged_on_id` int(11) DEFAULT NULL,
  `language_id` int(11) NOT NULL,
  `problem_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `contest_object_id` int(11) DEFAULT NULL,
  `judged_date` datetime(6) DEFAULT NULL,
  `locked_after` datetime(6) DEFAULT NULL,
  `rejudged_date` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `judge_submission_judged_on_id_ef7707ef_fk_judge_judge_id` (`judged_on_id`),
  KEY `judge_submission_date_14094309` (`date`),
  KEY `judge_submission_status_3f629ced` (`status`),
  KEY `judge_submi_problem_8d5e0a_idx` (`problem_id`,`user_id`,`points` DESC,`time` DESC),
  KEY `judge_submi_result_7a005c_idx` (`result`,`id` DESC),
  KEY `judge_submi_result_ba9a62_idx` (`result`,`language_id`,`id` DESC),
  KEY `judge_submi_languag_dfe850_idx` (`language_id`,`id` DESC),
  KEY `judge_submi_result_a77e42_idx` (`result`,`problem_id`),
  KEY `judge_submi_languag_380ab4_idx` (`language_id`,`problem_id`,`result`),
  KEY `judge_submi_problem_49f8ec_idx` (`problem_id`,`result`),
  KEY `judge_submi_user_id_650db3_idx` (`user_id`,`problem_id`,`result`),
  KEY `judge_submi_user_id_ec9a4b_idx` (`user_id`,`result`),
  KEY `judge_submi_contest_59fbe3_idx` (`contest_object_id`,`problem_id`,`user_id`,`points` DESC,`time` DESC),
  CONSTRAINT `judge_submission_contest_object_id_c5586240_fk_judge_contest_id` FOREIGN KEY (`contest_object_id`) REFERENCES `judge_contest` (`id`),
  CONSTRAINT `judge_submission_judged_on_id_ef7707ef_fk_judge_judge_id` FOREIGN KEY (`judged_on_id`) REFERENCES `judge_judge` (`id`),
  CONSTRAINT `judge_submission_language_id_48a75504_fk_judge_language_id` FOREIGN KEY (`language_id`) REFERENCES `judge_language` (`id`),
  CONSTRAINT `judge_submission_problem_id_d2fabe38_fk_judge_problem_id` FOREIGN KEY (`problem_id`) REFERENCES `judge_problem` (`id`),
  CONSTRAINT `judge_submission_user_id_9764487f_fk_judge_profile_id` FOREIGN KEY (`user_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_submissionsource`
--

DROP TABLE IF EXISTS `judge_submissionsource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_submissionsource` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source` longtext NOT NULL,
  `submission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `submission_id` (`submission_id`),
  CONSTRAINT `judge_submissionsour_submission_id_d4abc888_fk_judge_sub` FOREIGN KEY (`submission_id`) REFERENCES `judge_submission` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_submissiontestcase`
--

DROP TABLE IF EXISTS `judge_submissiontestcase`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_submissiontestcase` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `case` int(11) NOT NULL,
  `status` varchar(3) NOT NULL,
  `time` double DEFAULT NULL,
  `memory` double DEFAULT NULL,
  `points` double DEFAULT NULL,
  `total` double DEFAULT NULL,
  `batch` int(11) DEFAULT NULL,
  `feedback` varchar(50) NOT NULL,
  `extended_feedback` longtext NOT NULL,
  `output` longtext NOT NULL,
  `submission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_submissiontestcase_submission_id_case_7aba3b7b_uniq` (`submission_id`,`case`),
  CONSTRAINT `judge_submissiontest_submission_id_a69f2d0e_fk_judge_sub` FOREIGN KEY (`submission_id`) REFERENCES `judge_submission` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_ticket`
--

DROP TABLE IF EXISTS `judge_ticket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_ticket` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `time` datetime(6) NOT NULL,
  `notes` longtext NOT NULL,
  `object_id` int(10) unsigned NOT NULL CHECK (`object_id` >= 0),
  `is_open` tinyint(1) NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `judge_ticket_content_type_id_376ebcf9_fk_django_content_type_id` (`content_type_id`),
  KEY `judge_ticket_user_id_5a5c0bce_fk_judge_profile_id` (`user_id`),
  CONSTRAINT `judge_ticket_content_type_id_376ebcf9_fk_django_content_type_id` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `judge_ticket_user_id_5a5c0bce_fk_judge_profile_id` FOREIGN KEY (`user_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_ticket_assignees`
--

DROP TABLE IF EXISTS `judge_ticket_assignees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_ticket_assignees` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ticket_id` int(11) NOT NULL,
  `profile_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `judge_ticket_assignees_ticket_id_profile_id_6bdac784_uniq` (`ticket_id`,`profile_id`),
  KEY `judge_ticket_assignees_profile_id_84d298d8_fk_judge_profile_id` (`profile_id`),
  CONSTRAINT `judge_ticket_assignees_profile_id_84d298d8_fk_judge_profile_id` FOREIGN KEY (`profile_id`) REFERENCES `judge_profile` (`id`),
  CONSTRAINT `judge_ticket_assignees_ticket_id_0fd7b2f7_fk_judge_ticket_id` FOREIGN KEY (`ticket_id`) REFERENCES `judge_ticket` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_ticketmessage`
--

DROP TABLE IF EXISTS `judge_ticketmessage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_ticketmessage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `body` longtext NOT NULL,
  `time` datetime(6) NOT NULL,
  `ticket_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `judge_ticketmessage_ticket_id_5e413158_fk_judge_ticket_id` (`ticket_id`),
  KEY `judge_ticketmessage_user_id_1dbfbfb0_fk_judge_profile_id` (`user_id`),
  CONSTRAINT `judge_ticketmessage_ticket_id_5e413158_fk_judge_ticket_id` FOREIGN KEY (`ticket_id`) REFERENCES `judge_ticket` (`id`),
  CONSTRAINT `judge_ticketmessage_user_id_1dbfbfb0_fk_judge_profile_id` FOREIGN KEY (`user_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `judge_webauthncredential`
--

DROP TABLE IF EXISTS `judge_webauthncredential`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `judge_webauthncredential` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `cred_id` varchar(255) NOT NULL,
  `public_key` longtext NOT NULL,
  `counter` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cred_id` (`cred_id`),
  KEY `judge_webauthncredential_user_id_8eaad7d2_fk_judge_profile_id` (`user_id`),
  CONSTRAINT `judge_webauthncredential_user_id_8eaad7d2_fk_judge_profile_id` FOREIGN KEY (`user_id`) REFERENCES `judge_profile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `registration_registrationprofile`
--

DROP TABLE IF EXISTS `registration_registrationprofile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `registration_registrationprofile` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `activation_key` varchar(64) NOT NULL,
  `user_id` int(11) NOT NULL,
  `activated` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `registration_registr_user_id_5fcbf725_fk_auth_user` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `registration_supervisedregistrationprofile`
--

DROP TABLE IF EXISTS `registration_supervisedregistrationprofile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `registration_supervisedregistrationprofile` (
  `registrationprofile_ptr_id` int(11) NOT NULL,
  PRIMARY KEY (`registrationprofile_ptr_id`),
  CONSTRAINT `registration_supervi_registrationprofile__0a59f3b2_fk_registrat` FOREIGN KEY (`registrationprofile_ptr_id`) REFERENCES `registration_registrationprofile` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reversion_revision`
--

DROP TABLE IF EXISTS `reversion_revision`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reversion_revision` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date_created` datetime(6) NOT NULL,
  `comment` longtext NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `reversion_revision_user_id_17095f45_fk_auth_user_id` (`user_id`),
  KEY `reversion_revision_date_created_96f7c20c` (`date_created`),
  CONSTRAINT `reversion_revision_user_id_17095f45_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reversion_version`
--

DROP TABLE IF EXISTS `reversion_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reversion_version` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `object_id` varchar(191) NOT NULL,
  `format` varchar(255) NOT NULL,
  `serialized_data` longtext NOT NULL,
  `object_repr` longtext NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `revision_id` int(11) NOT NULL,
  `db` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `reversion_version_db_content_type_id_objec_b2c54f65_uniq` (`db`,`content_type_id`,`object_id`,`revision_id`),
  KEY `reversion_version_revision_id_af9f6a9d_fk_reversion_revision_id` (`revision_id`),
  KEY `reversion_v_content_f95daf_idx` (`content_type_id`,`db`),
  CONSTRAINT `reversion_version_content_type_id_7d0ff25c_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `reversion_version_revision_id_af9f6a9d_fk_reversion_revision_id` FOREIGN KEY (`revision_id`) REFERENCES `reversion_revision` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `social_auth_association`
--

DROP TABLE IF EXISTS `social_auth_association`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `social_auth_association` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `server_url` varchar(255) NOT NULL,
  `handle` varchar(255) NOT NULL,
  `secret` varchar(255) NOT NULL,
  `issued` int(11) NOT NULL,
  `lifetime` int(11) NOT NULL,
  `assoc_type` varchar(64) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `social_auth_association_server_url_handle_078befa2_uniq` (`server_url`,`handle`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `social_auth_code`
--

DROP TABLE IF EXISTS `social_auth_code`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `social_auth_code` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(254) NOT NULL,
  `code` varchar(32) NOT NULL,
  `verified` tinyint(1) NOT NULL,
  `timestamp` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `social_auth_code_email_code_801b2d02_uniq` (`email`,`code`),
  KEY `social_auth_code_code_a2393167` (`code`),
  KEY `social_auth_code_timestamp_176b341f` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `social_auth_nonce`
--

DROP TABLE IF EXISTS `social_auth_nonce`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `social_auth_nonce` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `server_url` varchar(255) NOT NULL,
  `timestamp` int(11) NOT NULL,
  `salt` varchar(65) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `social_auth_nonce_server_url_timestamp_salt_f6284463_uniq` (`server_url`,`timestamp`,`salt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `social_auth_partial`
--

DROP TABLE IF EXISTS `social_auth_partial`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `social_auth_partial` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `token` varchar(32) NOT NULL,
  `next_step` smallint(5) unsigned NOT NULL CHECK (`next_step` >= 0),
  `backend` varchar(32) NOT NULL,
  `data` longtext NOT NULL,
  `timestamp` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `social_auth_partial_token_3017fea3` (`token`),
  KEY `social_auth_partial_timestamp_50f2119f` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `social_auth_usersocialauth`
--

DROP TABLE IF EXISTS `social_auth_usersocialauth`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `social_auth_usersocialauth` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `provider` varchar(32) NOT NULL,
  `uid` varchar(255) NOT NULL,
  `extra_data` longtext NOT NULL,
  `user_id` int(11) NOT NULL,
  `created` datetime(6) NOT NULL,
  `modified` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `social_auth_usersocialauth_provider_uid_e6b5e668_uniq` (`provider`,`uid`),
  KEY `social_auth_usersocialauth_user_id_17d28448_fk_auth_user_id` (`user_id`),
  KEY `social_auth_usersocialauth_uid_796e51dc` (`uid`),
  CONSTRAINT `social_auth_usersocialauth_user_id_17d28448_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-27  2:58:27
