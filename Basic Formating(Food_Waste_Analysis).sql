USE Food_Waste_Analysis;

SELECT * FROM providers_data;

--- Checking Null Values ---
EXEC sp_help 'providers_data';
--- ltering and enforcing no null behaviour -- 
ALTER TABLE providers_data
ALTER COLUMN provider_id BIGINT NOT NULL;

ALTER TABLE providers_data
ALTER COLUMN name VARCHAR(255) NOT NULL;

ALTER TABLE providers_data
ALTER COLUMN type VARCHAR(100) NOT NULL;

ALTER TABLE providers_data
ALTER COLUMN address VARCHAR(255) NOT NULL;

ALTER TABLE providers_data
ALTER COLUMN city VARCHAR(100) NOT NULL;

ALTER TABLE providers_data
ALTER COLUMN contact VARCHAR(50) NOT NULL;

EXEC sp_help 'providers_data';

--- new datat checking ---
SELECT * FROM receivers_data;

--- understqanding columns are allowing null or not ---
EXEC sp_help 'receivers_data';

--- changinign nullable to no ---
ALTER TABLE receivers_data ALTER COLUMN receiver_id BIGINT NOT NULL;

ALTER TABLE receivers_data ALTER COLUMN name VARCHAR(255) NOT NULL;

ALTER TABLE receivers_data ALTER COLUMN type VARCHAR(100) NOT NULL;

ALTER TABLE receivers_data ALTER COLUMN city VARCHAR(100) NOT NULL;

ALTER TABLE receivers_data ALTER COLUMN contact VARCHAR(50) NOT NULL;

EXEC sp_help 'receivers_data';

SELECT * FROM food_listings_data;

EXEC sp_help 'food_listings_data';

ALTER TABLE food_listings_data ALTER COLUMN food_id BIGINT NOT NULL;

ALTER TABLE food_listings_data ALTER COLUMN food_name VARCHAR(255) NOT NULL;

ALTER TABLE food_listings_data ALTER COLUMN quantity BIGINT NOT NULL;

ALTER TABLE food_listings_data ALTER COLUMN expiry_date DATE NOT NULL;

ALTER TABLE food_listings_data ALTER COLUMN provider_id BIGINT NOT NULL;

ALTER TABLE food_listings_data ALTER COLUMN provider_type VARCHAR(100) NOT NULL;

ALTER TABLE food_listings_data ALTER COLUMN location VARCHAR(100) NOT NULL;

ALTER TABLE food_listings_data ALTER COLUMN food_type VARCHAR(100) NOT NULL;

ALTER TABLE food_listings_data ALTER COLUMN meal_type VARCHAR(100) NOT NULL;

EXEC sp_help 'food_listings_data';

SELECT * FROM claims_data;
EXEC SP_HELP 'claims_data';

ALTER TABLE claims_data ALTER COLUMN claim_id BIGINT NOT NULL;

ALTER TABLE claims_data ALTER COLUMN food_id BIGINT NOT NULL;

ALTER TABLE claims_data ALTER COLUMN receiver_id BIGINT NOT NULL;

ALTER TABLE claims_data ALTER COLUMN status VARCHAR(50) NOT NULL;

ALTER TABLE claims_data ALTER COLUMN timestamp DATETIME NOT NULL;

EXEC sp_help 'claims_data';