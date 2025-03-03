USE [CT dwh 01 Stage]
GO
/****** Object:  Schema [werne]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [werne]
GO
/****** Object:  Schema [translation]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [translation]
GO
/****** Object:  Schema [signavio]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [signavio]
GO
/****** Object:  Schema [settlement]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [settlement]
GO
/****** Object:  Schema [servicecloud]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [servicecloud]
GO
/****** Object:  Schema [sap]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [sap]
GO
/****** Object:  Schema [sales]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [sales]
GO
/****** Object:  Schema [returns]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [returns]
GO
/****** Object:  Schema [plentymarket]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [plentymarket]
GO
/****** Object:  Schema [parcellab]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [parcellab]
GO
/****** Object:  Schema [oxidshop]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [oxidshop]
GO
/****** Object:  Schema [Northampton]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [Northampton]
GO
/****** Object:  Schema [monitoring]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [monitoring]
GO
/****** Object:  Schema [kali]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [kali]
GO
/****** Object:  Schema [hoppegarten]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [hoppegarten]
GO
/****** Object:  Schema [forecast]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [forecast]
GO
/****** Object:  Schema [ebay]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [ebay]
GO
/****** Object:  Schema [cognigy]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [cognigy]
GO
/****** Object:  Schema [cdiscount]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [cdiscount]
GO
/****** Object:  Schema [carriercost]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [carriercost]
GO
/****** Object:  Schema [bratislava]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [bratislava]
GO
/****** Object:  Schema [amazon]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [amazon]
GO
/****** Object:  Schema [akeneo]    Script Date: 09/10/2024 14:13:21 ******/
DROP SCHEMA IF EXISTS [akeneo]
GO
/****** Object:  Schema [akeneo]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [akeneo]
GO
/****** Object:  Schema [amazon]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [amazon]
GO
/****** Object:  Schema [bratislava]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [bratislava]
GO
/****** Object:  Schema [carriercost]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [carriercost]
GO
/****** Object:  Schema [cdiscount]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [cdiscount]
GO
/****** Object:  Schema [cognigy]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [cognigy]
GO
/****** Object:  Schema [ebay]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [ebay]
GO
/****** Object:  Schema [forecast]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [forecast]
GO
/****** Object:  Schema [hoppegarten]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [hoppegarten]
GO
/****** Object:  Schema [kali]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [kali]
GO
/****** Object:  Schema [monitoring]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [monitoring]
GO
/****** Object:  Schema [Northampton]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [Northampton]
GO
/****** Object:  Schema [oxidshop]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [oxidshop]
GO
/****** Object:  Schema [parcellab]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [parcellab]
GO
/****** Object:  Schema [plentymarket]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [plentymarket]
GO
/****** Object:  Schema [returns]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [returns]
GO
/****** Object:  Schema [sales]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [sales]
GO
/****** Object:  Schema [sap]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [sap]
GO
/****** Object:  Schema [servicecloud]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [servicecloud]
GO
/****** Object:  Schema [settlement]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [settlement]
GO
/****** Object:  Schema [signavio]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [signavio]
GO
/****** Object:  Schema [translation]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [translation]
GO
/****** Object:  Schema [werne]    Script Date: 09/10/2024 14:13:21 ******/
CREATE SCHEMA [werne]
GO
