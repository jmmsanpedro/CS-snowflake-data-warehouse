/*
============================================
Create Database and Schemas
============================================
Script Purpose:
    This script creates a new database named 'SALES'.
    Also, the script sets up three schemas within the database:
    'BRONZE', 'SILVER' and 'GOLD'.

*/

USE ROLE SYSADMIN;

-- Create the SALES database
CREATE OR REPLACE DATABASE SALES;

USE DATABASE SALES;

-- Create Schemas
CREATE SCHEMA BRONZE;
CREATE SCHEMA SILVER;
CREATE SCHEMA GOLD;
