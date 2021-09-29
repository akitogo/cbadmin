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
-- Table structure for table `cbadmin_cfgLanguage`
--

DROP TABLE IF EXISTS `cbadmin_cfgLanguage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cbadmin_cfgLanguage` (
  `languageId` int NOT NULL AUTO_INCREMENT,
  `createdDate` datetime NOT NULL,
  `modifiedDate` datetime NOT NULL,
  `isDeleted` bit(1) NOT NULL DEFAULT b'0',
  `locale` varchar(5) NOT NULL,
  `name` varchar(20) NOT NULL,
  PRIMARY KEY (`languageId`),
  KEY `idx_createDate` (`createdDate`),
  KEY `idx_modifiedDate` (`modifiedDate`),
  KEY `idx_deleted` (`isDeleted`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cbadmin_cfgLanguage`
--

LOCK TABLES `cbadmin_cfgLanguage` WRITE;
/*!40000 ALTER TABLE `cbadmin_cfgLanguage` DISABLE KEYS */;
INSERT INTO `cbadmin_cfgLanguage` VALUES (1,now(),now(),'\0','en_EN','English');
/*!40000 ALTER TABLE `cbadmin_cfgLanguage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cbadmin_groupPermissions`
--

DROP TABLE IF EXISTS `cbadmin_groupPermissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cbadmin_groupPermissions` (
  `FK_permissionGroupId` int NOT NULL,
  `FK_permissionId` int NOT NULL,
  KEY `FKDBAC6294F4497DC2` (`FK_permissionGroupId`),
  KEY `FKDBAC629437C1A3F2` (`FK_permissionId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cbadmin_groupPermissions`
--

LOCK TABLES `cbadmin_groupPermissions` WRITE;
/*!40000 ALTER TABLE `cbadmin_groupPermissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `cbadmin_groupPermissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cbadmin_loginAttempts`
--

DROP TABLE IF EXISTS `cbadmin_loginAttempts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cbadmin_loginAttempts` (
  `loginAttemptsID` int NOT NULL AUTO_INCREMENT,
  `createdDate` datetime NOT NULL,
  `modifiedDate` datetime NOT NULL,
  `isDeleted` bit(1) NOT NULL DEFAULT b'0',
  `value` varchar(255) NOT NULL,
  `attempts` int NOT NULL,
  `lastLoginSuccessIP` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`loginAttemptsID`),
  KEY `idx_createDate` (`createdDate`),
  KEY `idx_modifiedDate` (`modifiedDate`),
  KEY `idx_values` (`value`),
  KEY `idx_deleted` (`isDeleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cbadmin_loginAttempts`
--

LOCK TABLES `cbadmin_loginAttempts` WRITE;
/*!40000 ALTER TABLE `cbadmin_loginAttempts` DISABLE KEYS */;
/*!40000 ALTER TABLE `cbadmin_loginAttempts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cbadmin_permission`
--

DROP TABLE IF EXISTS `cbadmin_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cbadmin_permission` (
  `permissionId` int NOT NULL AUTO_INCREMENT,
  `createdDate` datetime NOT NULL,
  `modifiedDate` datetime NOT NULL,
  `isDeleted` bit(1) NOT NULL DEFAULT b'0',
  `permission` varchar(255) NOT NULL,
  `description` longtext,
  PRIMARY KEY (`permissionId`),
  UNIQUE KEY `permission` (`permission`),
  KEY `idx_createDate` (`createdDate`),
  KEY `idx_modifiedDate` (`modifiedDate`),
  KEY `idx_deleted` (`isDeleted`),
  KEY `idx_permissionName` (`permission`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cbadmin_permission`
--

LOCK TABLES `cbadmin_permission` WRITE;
/*!40000 ALTER TABLE `cbadmin_permission` DISABLE KEYS */;
/*!40000 ALTER TABLE `cbadmin_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cbadmin_permissionGroup`
--

DROP TABLE IF EXISTS `cbadmin_permissionGroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cbadmin_permissionGroup` (
  `permissionGroupId` int NOT NULL AUTO_INCREMENT,
  `createdDate` datetime NOT NULL,
  `modifiedDate` datetime NOT NULL,
  `isDeleted` bit(1) NOT NULL DEFAULT b'0',
  `name` varchar(255) NOT NULL,
  `description` longtext,
  PRIMARY KEY (`permissionGroupId`),
  UNIQUE KEY `name` (`name`),
  KEY `idx_permissionGroupName` (`name`),
  KEY `idx_createDate` (`createdDate`),
  KEY `idx_modifiedDate` (`modifiedDate`),
  KEY `idx_deleted` (`isDeleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cbadmin_permissionGroup`
--

LOCK TABLES `cbadmin_permissionGroup` WRITE;
/*!40000 ALTER TABLE `cbadmin_permissionGroup` DISABLE KEYS */;
/*!40000 ALTER TABLE `cbadmin_permissionGroup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cbadmin_role`
--

DROP TABLE IF EXISTS `cbadmin_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cbadmin_role` (
  `roleId` int NOT NULL AUTO_INCREMENT,
  `createdDate` datetime NOT NULL,
  `modifiedDate` datetime NOT NULL,
  `isDeleted` bit(1) NOT NULL DEFAULT b'0',
  `role` varchar(255) NOT NULL,
  `description` longtext,
  PRIMARY KEY (`roleId`),
  UNIQUE KEY `role` (`role`),
  KEY `idx_createDate` (`createdDate`),
  KEY `idx_modifiedDate` (`modifiedDate`),
  KEY `idx_deleted` (`isDeleted`),
  KEY `idx_roleName` (`role`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cbadmin_role`
--

LOCK TABLES `cbadmin_role` WRITE;
/*!40000 ALTER TABLE `cbadmin_role` DISABLE KEYS */;
INSERT INTO `cbadmin_role` VALUES (1,now(),now(),'\0','Admin','(admin role)'),(2,now(),now(),'\0','User','(user role)');
/*!40000 ALTER TABLE `cbadmin_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cbadmin_rolePermissions`
--

DROP TABLE IF EXISTS `cbadmin_rolePermissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cbadmin_rolePermissions` (
  `FK_permissionId` int NOT NULL,
  `FK_roleId` int NOT NULL,
  KEY `FK4345E63F9724FA40` (`FK_roleId`),
  KEY `FK4345E63F37C1A3F2` (`FK_permissionId`),
  CONSTRAINT `FK4345E63F37C1A3F2` FOREIGN KEY (`FK_permissionId`) REFERENCES `cbadmin_permission` (`permissionId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cbadmin_rolePermissions`
--

LOCK TABLES `cbadmin_rolePermissions` WRITE;
/*!40000 ALTER TABLE `cbadmin_rolePermissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `cbadmin_rolePermissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cbadmin_securityRule`
--

DROP TABLE IF EXISTS `cbadmin_securityRule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cbadmin_securityRule` (
  `ruleID` int NOT NULL AUTO_INCREMENT,
  `createdDate` datetime NOT NULL,
  `modifiedDate` datetime NOT NULL,
  `isDeleted` bit(1) NOT NULL DEFAULT b'0',
  `whitelist` varchar(255) DEFAULT NULL,
  `securelist` varchar(255) NOT NULL,
  `match` varchar(50) DEFAULT 'event',
  `roles` varchar(255) DEFAULT NULL,
  `permissions` longtext,
  `redirect` longtext NOT NULL,
  `overrideEvent` longtext NOT NULL,
  `useSSL` bit(1) DEFAULT b'0',
  `action` varchar(50) DEFAULT 'redirect',
  `module` longtext,
  `order` int NOT NULL,
  `message` varchar(255) DEFAULT NULL,
  `messageType` varchar(50) DEFAULT 'info',
  PRIMARY KEY (`ruleID`),
  KEY `idx_createDate` (`createdDate`),
  KEY `idx_modifiedDate` (`modifiedDate`),
  KEY `idx_deleted` (`isDeleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cbadmin_securityRule`
--

LOCK TABLES `cbadmin_securityRule` WRITE;
/*!40000 ALTER TABLE `cbadmin_securityRule` DISABLE KEYS */;
/*!40000 ALTER TABLE `cbadmin_securityRule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cbadmin_setting`
--

DROP TABLE IF EXISTS `cbadmin_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cbadmin_setting` (
  `settingID` int NOT NULL AUTO_INCREMENT,
  `createdDate` datetime NOT NULL,
  `modifiedDate` datetime NOT NULL,
  `isDeleted` bit(1) NOT NULL DEFAULT b'0',
  `name` varchar(100) NOT NULL,
  `value` longtext NOT NULL,
  `isCore` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`settingID`),
  KEY `idx_createDate` (`createdDate`),
  KEY `idx_modifiedDate` (`modifiedDate`),
  KEY `idx_core` (`isCore`),
  KEY `idx_deleted` (`isDeleted`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cbadmin_setting`
--

LOCK TABLES `cbadmin_setting` WRITE;
/*!40000 ALTER TABLE `cbadmin_setting` DISABLE KEYS */;
INSERT INTO `cbadmin_setting` VALUES (1,now(),now(),'\0','CBADMIN_MAIL_SERVER','127.0.0.1','\0'),(2,now(),now(),'\0','cbadmin_outgoingEmail','info@example.com','\0'),(3,now(),now(),'\0','cbadmin_email','admin@example.com','\0');
/*!40000 ALTER TABLE `cbadmin_setting` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cbadmin_user`
--

DROP TABLE IF EXISTS `cbadmin_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cbadmin_user` (
  `userId` int NOT NULL AUTO_INCREMENT,
  `createdDate` datetime NOT NULL,
  `modifiedDate` datetime NOT NULL,
  `isDeleted` bit(1) NOT NULL DEFAULT b'0',
  `firstName` varchar(100) NOT NULL,
  `lastName` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `username` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `isActive` bit(1) NOT NULL,
  `lastLogin` datetime DEFAULT NULL,
  `preferences` longtext,
  `isPasswordReset` bit(1) NOT NULL DEFAULT b'0',
  `is2FactorAuth` bit(1) NOT NULL DEFAULT b'0',
  `FK_roleId` int DEFAULT NULL,
  `FK_LanguageId` int DEFAULT NULL,
  PRIMARY KEY (`userId`),
  UNIQUE KEY `username` (`username`),
  KEY `idx_login` (`username`,`password`,`isActive`),
  KEY `idx_createDate` (`createdDate`),
  KEY `idx_modifiedDate` (`modifiedDate`),
  KEY `idx_activeAuthor` (`isActive`),
  KEY `idx_passwordReset` (`isPasswordReset`),
  KEY `idx_email` (`email`),
  KEY `idx_deleted` (`isDeleted`),
  KEY `idx_2factorauth` (`is2FactorAuth`),
  KEY `FK2243BC5A9724FA40` (`FK_roleId`),
  KEY `FK2243BC5AE21B1E9` (`FK_LanguageId`),
  CONSTRAINT `FK2243BC5A9724FA40` FOREIGN KEY (`FK_roleId`) REFERENCES `cbadmin_role` (`roleId`),
  CONSTRAINT `FK2243BC5AE21B1E9` FOREIGN KEY (`FK_LanguageId`) REFERENCES `cbadmin_cfgLanguage` (`languageId`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cbadmin_user`
--

LOCK TABLES `cbadmin_user` WRITE;
/*!40000 ALTER TABLE `cbadmin_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `cbadmin_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cbadmin_userPermissionGroups`
--

DROP TABLE IF EXISTS `cbadmin_userPermissionGroups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cbadmin_userPermissionGroups` (
  `FK_permissionGroupId` int NOT NULL,
  `FK_userId` int NOT NULL,
  KEY `FK4792C0FDF4497DC2` (`FK_permissionGroupId`),
  KEY `FK4792C0FD9C7A4FAA` (`FK_userId`),
  CONSTRAINT `FK4792C0FD9C7A4FAA` FOREIGN KEY (`FK_userId`) REFERENCES `cbadmin_user` (`userId`),
  CONSTRAINT `FK4792C0FDF4497DC2` FOREIGN KEY (`FK_permissionGroupId`) REFERENCES `cbadmin_permissionGroup` (`permissionGroupId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cbadmin_userPermissionGroups`
--

LOCK TABLES `cbadmin_userPermissionGroups` WRITE;
/*!40000 ALTER TABLE `cbadmin_userPermissionGroups` DISABLE KEYS */;
/*!40000 ALTER TABLE `cbadmin_userPermissionGroups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cbadmin_userPermissions`
--

DROP TABLE IF EXISTS `cbadmin_userPermissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cbadmin_userPermissions` (
  `FK_userId` int NOT NULL,
  `FK_permissionId` int NOT NULL,
  KEY `FKB6BF83CA9C7A4FAA` (`FK_userId`),
  KEY `FKB6BF83CA37C1A3F2` (`FK_permissionId`),
  CONSTRAINT `FKB6BF83CA37C1A3F2` FOREIGN KEY (`FK_permissionId`) REFERENCES `cbadmin_permission` (`permissionId`),
  CONSTRAINT `FKB6BF83CA9C7A4FAA` FOREIGN KEY (`FK_userId`) REFERENCES `cbadmin_user` (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cbadmin_userPermissions`
--

LOCK TABLES `cbadmin_userPermissions` WRITE;
/*!40000 ALTER TABLE `cbadmin_userPermissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `cbadmin_userPermissions` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;