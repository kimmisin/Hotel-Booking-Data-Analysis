-- Viewing the dataset
SELECT * FROM hotel.2018 LIMIT 5;
SELECT * FROM hotel.2019 LIMIT 5;
SELECT * FROM hotel.2020 LIMIT 5;
SELECT * FROM hotel.market_segment LIMIT 5;
SELECT * FROM hotel.meal_cost LIMIT 5;

-- Seeing if any tables can be merged
SHOW COLUMNS FROM hotel.2018;
SHOW COLUMNS FROM hotel.2019;
SHOW COLUMNS FROM hotel.2020;
SHOW COLUMNS FROM hotel.market_segment;
SHOW COLUMNS FROM hotel.meal_cost;
-- tables 2018-2020 have the same data columns. Market_segment's discount can be added as an additonal column. Meal_cost can also be added as another column.

-- Merge the booking details into one new table
CREATE TABLE hotel.bookings AS
SELECT * FROM hotel.2018
UNION ALL
SELECT * FROM hotel.2019
UNION ALL
SELECT * FROM hotel.2020;

-- Confirm no data loss
SELECT
    IF(
        (SELECT COUNT(*) FROM hotel.2018) + 
        (SELECT COUNT(*) FROM hotel.2019) + 
        (SELECT COUNT(*) FROM hotel.2020) =
        (SELECT COUNT(*) FROM hotel.bookings),
        "No data loss", "Data was lost"
        ) AS result;

-- Merge market_segment and meal_cost to bookings
CREATE TABLE hotel.detailed_bookings AS
SELECT 
    bookings.hotel,
    bookings.is_canceled,
    bookings.lead_time,
    bookings.arrival_date_year,
    bookings.arrival_date_month,
    bookings.arrival_date_week_number,
    bookings.arrival_date_day_of_month,
    bookings.stays_in_weekend_nights,
    bookings.stays_in_week_nights,
    bookings.adults,
    bookings.children,
    bookings.babies,
    bookings.country,
    bookings.distribution_channel,
    bookings.is_repeated_guest,
    bookings.previous_cancellations,
    bookings.previous_bookings_not_canceled,
    bookings.reserved_room_type,
    bookings.assigned_room_type,
    bookings.booking_changes,
    bookings.deposit_type,
    bookings.agent,
    bookings.company,
    bookings.days_in_waiting_list,
    bookings.customer_type,
    bookings.adr,
    bookings.required_car_parking_spaces,
    bookings.total_of_special_requests,
    bookings.reservation_status,
    bookings.reservation_status_date,
    market_segment.market_segment,
    market_segment.discount,
    meal_cost.meal,
    meal_cost.Cost
FROM hotel.bookings
LEFT JOIN hotel.market_segment
ON bookings.market_segment = market_segment.market_segment
LEFT JOIN hotel.meal_cost
ON bookings.meal = meal_cost.meal;

-- Rename column Cost to meal_cost
ALTER TABLE hotel.detailed_bookings
CHANGE Cost meal_cost DOUBLE;

-- Question 1: Is hotel revenue growing each year?
-- Calculate renvue per year across both hotels (doesn't account for discounted market segments and meal costs)
SELECT arrival_date_year,
round(sum((stays_in_weekend_nights + stays_in_week_nights)*adr),2)
AS renvue
FROM detailed_bookings
WHERE is_canceled=0
GROUP BY arrival_date_year;

-- Calculate the revenue made per year for each hotel (doesn't account for discounted market segments and meal costs)
SELECT hotel, arrival_date_year,
round(sum((stays_in_weekend_nights + stays_in_week_nights)* adr ),2)
AS revenue
FROM detailed_bookings
WHERE is_canceled=0
GROUP BY arrival_date_year, hotel
ORDER BY hotel;
-- Both hotels had growing renvue from 2018 to 2019 but slowed in 2020. Decline may be due to COVID.

