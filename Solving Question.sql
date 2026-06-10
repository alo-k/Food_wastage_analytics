USE Food_Waste_Analysis;

SELECT * FROM providers_data;
SELECT * FROM receivers_data;
SELECT * FROM food_listings_data;
SELECT * FROM claims_data;


--- first is that we want to check on hown we will decide where wastage is happening ---
SELECT
    f.food_id,
    c.claim_id,
    c.status
FROM food_listings_data f
LEFT JOIN claims_data c
ON f.food_id = c.food_id
ORDER BY f.food_id ASC;
---By joining the food listings and claims data, we analyzed how each food_id behaves in terms of claim activity and status.
----Key Findings:
---Three distinct scenarios identified for each food listing:
---No claims (NULL values) ? Indicates the food was never requested ? Potential wastage
---Claims exist but all are Cancelled/Pending ? No successful fulfillment ? Wastage
---At least one Completed claim exists ? Food was successfully received ? Not wasted
---Validation of data relationships:
---One food_id can have multiple claims
---Claims vary in status (Completed, Cancelled, Pending)
---Core logic for wastage defined:

---A food item is considered NOT wasted only if at least one claim is completed---

---- Now we will chek which food_id hasreally gone wasted   ---
SELECT
    f.food_id,
    CASE 
        WHEN SUM(CASE WHEN c.status = 'Completed' THEN 1 ELSE 0 END)>0
        THEN 'Not Wasted'
        ELSE 'Wasted'
    END AS food_status
FROM food_listings_data f
LEFT JOIN claims_data c
ON f.food_id=c.food_id
GROUP BY f.food_id
ORDER BY f.food_id ASC;

--- Wasted food are more as compared to non waste ----

--- HOW TO KNOW THE REASON WHY WASTE ARE MORE THAN NON WASTE ---
--- Quantity , expiry date and no claim are the 3 factors we ave to look on ---
--- Preparing dataset to analyze behaviour --- 
SELECT 
    fs.food_id,
    fs.food_status,
    f.expiry_date,
    c.timestamp,
    c.status
FROM(SELECT
    f.food_id,
        CASE 
        WHEN SUM(CASE WHEN c.status = 'Completed' THEN 1 ELSE 0 END)>0
        THEN 'Not Wasted'
        ELSE 'Wasted'
    END AS food_status
FROM food_listings_data f
LEFT JOIN claims_data c
ON f.food_id = c.food_id
GROUP BY f.food_id
) fs
LEFT JOIN food_listings_data f
ON fs.food_id = f.food_id
LEFT JOIN claims_data c
ON fs.food_id = c.food_id;

---- one food_id can have multipl claim and multiple timestamp with similar expiry date ---
SELECT 
    fs.food_id,
    fs.food_status,
    f.expiry_date,
    c.timestamp,
    c.status,
    DATEDIFF(HOUR, c.timestamp, f.expiry_date) AS time_to_expiry
FROM (
    SELECT
        f.food_id,
        CASE 
            WHEN SUM(CASE WHEN c.status = 'Completed' THEN 1 ELSE 0 END) > 0
            THEN 'Not Wasted'
            ELSE 'Wasted'
        END AS food_status
    FROM food_listings_data f
    LEFT JOIN claims_data c
    ON f.food_id = c.food_id
    GROUP BY f.food_id
) fs
LEFT JOIN food_listings_data f
ON fs.food_id = f.food_id
LEFT JOIN claims_data c
ON fs.food_id = c.food_id;

--- Analysis shows that while lower time-to-expiry can increase the likelihood of claim cancellations,
--- wastage is not solely driven by expiry timing. 
---A significant portion of wasted listings either received no claims (indicating lack of demand) or experienced failed claims due to operational inefficiencies.
---Therefore, expiry acts as a secondary factor impacting fulfillment rather than the primary cause of wastage.

---No-demand wastage: Food listings that received no claims at all, indicating lack of interest or visibility.

---Failed-demand wastage: Food listings that were claimed but not successfully completed (e.g., cancelled or stuck in pending), 
---indicating operational or timing issues.


---- lets check it with quantity , like is less quantity or more quantiy affecting fodd status
SELECT 
    fs.food_status,
    AVG(f.quantity) AS avg_quantity,
    COUNT(*) AS total_items
FROM (
        SELECT
        f.food_id,
        CASE 
            WHEN SUM(CASE WHEN c.status = 'Completed' THEN 1 ELSE 0 END) > 0
            THEN 'Not Wasted'
            ELSE 'Wasted'
        END AS food_status
    FROM food_listings_data f
    LEFT JOIN claims_data c
    ON f.food_id = c.food_id
    GROUP BY f.food_id
) AS fs
JOIN food_listings_data f
ON fs.food_id = f.food_id
GROUP BY fs.food_status;
--- Average quantity does not differentiate wasted vs non-wasted listings, 
---suggesting that quantity alone is not a primary driver of wastage at an aggregate level.

--- for status based avg quantity ---
SELECT 
    c.status,
    AVG(f.quantity) AS avg_quantity,
    COUNT(*) AS total_claims
FROM claims_data c
JOIN food_listings_data f
ON c.food_id = f.food_id
GROUP BY c.status;
 --- Average quantity does not significantly differ across claim statuses, 
 ---so it does not explain claim outcomes at an aggregate level.
 ---However, deeper analysis using distribution or segmentation is something i am looking forward too.

SELECT 
    quantity_bucket,
    food_status,
    COUNT(*) AS total_items
FROM (
    SELECT 
        f.food_id,
        CASE 
            WHEN f.quantity <= 5 THEN 'Low'
            WHEN f.quantity <= 15 THEN 'Medium'
            ELSE 'High'
        END AS quantity_bucket,
        CASE 
            WHEN SUM(CASE WHEN c.status = 'Completed' THEN 1 ELSE 0 END) > 0
            THEN 'Not Wasted'
            ELSE 'Wasted'
        END AS food_status
    FROM food_listings_data f
    LEFT JOIN claims_data c
    ON f.food_id = c.food_id
    GROUP BY f.food_id, f.quantity
) t
GROUP BY quantity_bucket, food_status;
--- Wastage percentage is consistently high (~70%) across all quantity buckets, 
---indicating that quantity alone is not a strong differentiating factor for wastage.

--- Final outcome ---
--- Analysis across quantity buckets shows consistently high wastage rates (~69–73%), 
----indicating that quantity does not significantly influence wastage. 
---This suggests that other factors such as demand visibility, timing, or claim execution are more critical drivers.



--- Business Question to answer ----
--- 1. How many food providers and receivers are there in each city? ---
SELECT 
    city,
    COUNT('reciever_id') AS total_reciever
FROM receivers_data
GROUP BY city;

SELECT 
    city,
    COUNT('provider_id') AS total_provider
FROM providers_data
GROUP BY city;

---- 2. Which type of food provider (restaurant, grocery store, etc.) contributes the most food? ---
SELECT 
    sum(quantity) AS total_quantity,
    provider_type
FROM food_listings_data
GROUP BY provider_type
ORDER BY sum(quantity) DESC;

--- 3. What is the contact information of food providers in a specific city?
SELECT
    provider_id,
    city,
    contact
FROM providers_data
WHERE city = 'New Jessica';  

--- 4. Which receivers have claimed the most food? ---
SELECT 
    receiver_id,
    COUNT(claim_id) AS total_claimed_food
FROM claims_data
GROUP BY receiver_id
ORDER BY COUNT(claim_id) DESC;

--- 5. What is the total quantity of food available from all providers? ---
SELECT 
    SUM(quantity) AS total_availaible
FROM food_listings_data;

--- 6. Which city has the highest number of food listings? ---
SELECT
    TOP 1
    location,
    COUNT(food_id) AS total_food_listing
FROM food_listings_data
Group BY location
ORDER BY COUNT(food_id) DESC;

--- 7. What are the most commonly available food types? ---
SELECT 
    food_type,
    COUNT(food_type) AS total_availability
FROM food_listings_data
GROUP BY (food_type)
ORDER BY COUNT(food_type) DESC;

--- 8. How many food claims have been made for each food item? ---
SELECT
    f.food_name,
    COUNT(c.claim_id) AS total_claim
FROM food_listings_data f
LEFT JOIN claims_data c
ON f.food_id=c.food_id
GROUP BY f.food_name;

--- 9. Which provider has had the highest number of successful food claims? ---
SELECT
    TOP 1
    f.provider_id,
    COUNT(c.claim_id) AS total_claim
FROM food_listings_data f
INNER JOIN claims_data c
ON f.food_id = c.food_id
WHERE c.status = 'Completed'
GROUP BY f.provider_id
ORDER BY COUNT(c.claim_id) DESC;

--- 10. What percentage of food claims are completed vs. pending vs. canceled? ---
SELECT
    status,
    ROUND(
            COUNT(*) *100.00/SUM(COUNT(*))
            OVER(),
            2
         ) AS total_percentage
FROM claims_data
GROUP BY status;

--- 11. What is the average quantity of food claimed per receiver? ---
SELECT 
    c.receiver_id,
    AVG(f.quantity) AS avg_claim_recieved
FROM food_listings_data f
INNER JOIN claims_data c
ON f.food_id = c.food_id
GROUP BY c.receiver_id;

--- USING WINDOWS FUNCION FOR THE SAME QUESTION ---
SELECT DISTINCT
        c.receiver_id,
        AVG(f.quantity) OVER(PARTITION BY c.receiver_id) AS avg_claim_received
FROM food_listings_data f
INNER JOIN claims_data c
ON f.food_id = c.food_id;

--- 12. Which meal type (breakfast, lunch, dinner, snacks) is claimed the most? ---
SELECT 
    TOP 1
    f.meal_type,
    COUNT(c.claim_id) AS total_claims
FROM food_listings_data f
INNER JOIN claims_data c
ON f.food_id = c.food_id
GROUP BY f.meal_type
ORDER BY total_claims DESC;

--- 13. What is the total quantity of food donated by each provider? ---
SELECT
    provider_id,
    SUM(quantity) AS total_quantity_donated
FROM food_listings_data
GROUP BY provider_id
ORDER BY SUM(quantity) DESC;