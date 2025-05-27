CREATE DATABASE IF NOT EXISTS rental_film_dw;

USE rental_film_dw;

/* Dimension Tables */
CREATE TABLE
    IF NOT EXISTS Dim_Date (
        date_key INT PRIMARY KEY,
        date DATE NOT NULL UNIQUE,
        day_of_week TINYINT UNSIGNED NOT NULL,
        day_name VARCHAR(10) NOT NULL,
        day_of_month TINYINT UNSIGNED NOT NULL,
        day_of_year SMALLINT UNSIGNED NOT NULL,
        week_of_year TINYINT UNSIGNED NOT NULL,
        month TINYINT UNSIGNED NOT NULL,
        month_name VARCHAR(10) NOT NULL,
        quarter TINYINT UNSIGNED NOT NULL,
        year SMALLINT UNSIGNED NOT NULL,
        fiscal_year SMALLINT,
        is_weekend BOOLEAN NOT NULL DEFAULT FALSE
    );

CREATE TABLE
    IF NOT EXISTS Dim_Staff (
        staff_key INT PRIMARY KEY AUTO_INCREMENT,
        staff_id TINYINT UNSIGNED NOT NULL UNIQUE,
        first_name VARCHAR(45) NOT NULL,
        last_name VARCHAR(45) NOT NULL,
        email VARCHAR(50),
        username VARCHAR(16) NOT NULL
    );

CREATE TABLE
    IF NOT EXISTS Dim_Film (
        film_key INT PRIMARY KEY AUTO_INCREMENT,
        film_id SMALLINT UNSIGNED NOT NULL UNIQUE,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        release_year YEAR,
        language_id TINYINT UNSIGNED,
        original_language_id TINYINT UNSIGNED,
        rental_duration TINYINT UNSIGNED NOT NULL,
        rental_rate DECIMAL(4, 2) NOT NULL,
        length SMALLINT UNSIGNED,
        replacement_cost DECIMAL(5, 2) NOT NULL,
        rating ENUM ('G', 'PG', 'PG-13', 'R', 'NC-17') DEFAULT 'G',
        special_features
        SET
            (
                'Trailers',
                'Commentaries',
                'Deleted Scenes',
                'Behind the Scenes'
            )
    );

CREATE TABLE
    IF NOT EXISTS Dim_Store (
        store_key INT PRIMARY KEY AUTO_INCREMENT,
        store_id TINYINT UNSIGNED NOT NULL UNIQUE,
        address_id SMALLINT UNSIGNED NOT NULL
    );

CREATE TABLE
    IF NOT EXISTS Dim_Rent (
        rent_key INT PRIMARY KEY AUTO_INCREMENT,
        rental_id INT UNSIGNED NOT NULL UNIQUE,
        inventory_id MEDIUMINT UNSIGNED NOT NULL,
        customer_id SMALLINT UNSIGNED NOT NULL,
        rental_date DATETIME NOT NULL,
        return_date DATETIME
    );

/* -------------- */
/* Fact Tables */
CREATE TABLE
    IF NOT EXISTS Fact_Monthly_Payment (
        date_key INT NOT NULL,
        staff_key INT NOT NULL,
        rent_key INT NOT NULL,
        payment_amount DECIMAL(5, 2) NOT NULL,
        payment_count INT UNSIGNED NOT NULL,
        PRIMARY KEY (date_key, staff_key, rent_key),
        CONSTRAINT fk_fact_monthly_payment_date FOREIGN KEY (date_key) REFERENCES Dim_Date (date_key),
        CONSTRAINT fk_fact_monthly_payment_staff FOREIGN KEY (staff_key) REFERENCES Dim_Staff (staff_key),
        CONSTRAINT fk_fact_monthly_payment_rent FOREIGN KEY (rent_key) REFERENCES Dim_Rent (rent_key)
    );

CREATE TABLE
    IF NOT EXISTS Fact_Daily_Inventory (
        date_key INT NOT NULL,
        film_key INT NOT NULL,
        store_key INT NOT NULL,
        inventory_count INT UNSIGNED NOT NULL,
        PRIMARY KEY (date_key, film_key, store_key),
        CONSTRAINT fk_fact_daily_inventory_date FOREIGN KEY (date_key) REFERENCES Dim_Date (date_key),
        CONSTRAINT fk_fact_daily_inventory_film FOREIGN KEY (film_key) REFERENCES Dim_Film (film_key),
        CONSTRAINT fk_fact_daily_inventory_store FOREIGN KEY (store_key) REFERENCES Dim_Store (store_key)
    );

/* -------------- */