CREATE TABLE patients (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    gender VARCHAR(10) CHECK (gender IN ('Male', 'Female', 'Other')),
    date_of_birth DATE,
    phone VARCHAR(15),
    email VARCHAR(100) UNIQUE,
    address TEXT,
    blood_group VARCHAR(5),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(15),
    registration_date DATE DEFAULT CURRENT_DATE
);
select * from patients
INSERT INTO patients (
    first_name, last_name, gender, date_of_birth, phone, email, address,
    blood_group, emergency_contact_name, emergency_contact_phone, registration_date
)
SELECT 
    'First' || i,
    'Last' || i,
    CASE WHEN i % 3 = 0 THEN 'Male'
         WHEN i % 3 = 1 THEN 'Female'
         ELSE 'Other'
    END,
    DATE '1980-01-01' + (i % 1000),
    '999999' || lpad(i::text, 4, '0'),
    'user' || i || '@example.com',
    'Address ' || i,
    CASE WHEN i % 4 = 0 THEN 'A+'
         WHEN i % 4 = 1 THEN 'B+'
         WHEN i % 4 = 2 THEN 'O+'
         ELSE 'AB-'
    END,
    'Emergency' || i,
    '888888' || lpad(i::text, 4, '0'),
    CURRENT_DATE - (i % 365)
FROM generate_series(1, 500) AS s(i);

CREATE TABLE doctors (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    gender VARCHAR(10) CHECK (gender IN ('Male', 'Female', 'Other')),
    date_of_birth DATE,
    phone VARCHAR(15),
    email VARCHAR(100) UNIQUE,
    address TEXT,
    specialization VARCHAR(100),
    department VARCHAR(100),
    qualification VARCHAR(100),
    years_of_experience INT CHECK (years_of_experience >= 0),
    joining_date DATE DEFAULT CURRENT_DATE,
    availability_days VARCHAR(50), -- e.g. 'Mon-Fri'
    availability_time VARCHAR(50)  -- e.g. '10:00 AM - 4:00 PM'
);
select * from doctors

INSERT INTO doctors (
    first_name, last_name, gender, date_of_birth, phone, email, address,
    specialization, department, qualification, years_of_experience,
    joining_date, availability_days, availability_time
)
SELECT
    'DoctorFirst' || i,
    'DoctorLast' || i,
    CASE WHEN i % 3 = 0 THEN 'Male'
         WHEN i % 3 = 1 THEN 'Female'
         ELSE 'Other'
    END,
    DATE '1970-01-01' + (i % 15000),
    '99999' || lpad(i::text, 5, '0'),
    'doctor' || i || '@hospital.com',
    'Address Block ' || (i % 50),
    CASE WHEN i % 5 = 0 THEN 'Cardiologist'
         WHEN i % 5 = 1 THEN 'Neurologist'
         WHEN i % 5 = 2 THEN 'Orthopedic'
         WHEN i % 5 = 3 THEN 'Dermatologist'
         ELSE 'General Physician'
    END,
    CASE WHEN i % 4 = 0 THEN 'Cardiology'
         WHEN i % 4 = 1 THEN 'Neurology'
         WHEN i % 4 = 2 THEN 'Orthopedics'
         ELSE 'General Medicine'
    END,
    CASE WHEN i % 3 = 0 THEN 'MBBS'
         WHEN i % 3 = 1 THEN 'MD'
         ELSE 'MS'
    END,
    (i % 40),
    CURRENT_DATE - (i % 3650),
    CASE WHEN i % 2 = 0 THEN 'Mon-Fri' ELSE 'Tue-Thu' END,
    CASE WHEN i % 2 = 0 THEN '9:00 AM - 1:00 PM' ELSE '2:00 PM - 6:00 PM' END
FROM generate_series(1, 500) AS s(i);

select * from doctors

CREATE TABLE appointments (
    id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(id) ON DELETE CASCADE,
    doctor_id INT REFERENCES doctors(id) ON DELETE SET NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status VARCHAR(20) CHECK (status IN ('Scheduled', 'Completed', 'Cancelled')) DEFAULT 'Scheduled',
    reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

select * from appointments

INSERT INTO appointments (
    patient_id,
    doctor_id,
    appointment_date,
    appointment_time,
    status,
    reason,
    created_at
)
SELECT
    (i % 500) + 1,  -- Random patient_id from 1 to 500
    (i % 100) + 1,  -- Random doctor_id from 1 to 100
    CURRENT_DATE + (i % 30), -- Spread across next 30 days
    TIME '09:00:00' + (i % 8) * INTERVAL '1 hour', -- 9AM to 5PM slots
    CASE 
        WHEN i % 5 = 0 THEN 'Cancelled'
        WHEN i % 3 = 0 THEN 'Completed'
        ELSE 'Scheduled'
    END,
    'General check-up or follow-up visit #' || i,
    CURRENT_TIMESTAMP - (i % 100) * INTERVAL '1 day'
FROM generate_series(1, 500) AS s(i);

select * from appointments

CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    head_of_department VARCHAR(100),
    contact_number VARCHAR(15),
    email VARCHAR(100),
    floor_number INT,
    description TEXT
);


select * from departments

INSERT INTO departments (
    name,
    head_of_department,
    contact_number,
    email,
    floor_number,
    description
)
SELECT
    dept_names[i % array_length(dept_names, 1) + 1],
    'Dr. ' || initcap(dept_names[i % array_length(dept_names, 1) + 1]) || ' Head ' || i,
    '98765' || lpad(i::text, 5, '0'),
    lower(dept_names[i % array_length(dept_names, 1) + 1]) || i || '@hospital.com',
    (i % 10) + 1,
    'This is the ' || dept_names[i % array_length(dept_names, 1) + 1] || ' department located on floor ' || ((i % 10) + 1) || '.'
FROM generate_series(1, 500) AS s(i),
     (SELECT ARRAY[
         'Cardiology', 'Neurology', 'Orthopedics', 'Dermatology', 'Pediatrics',
         'Emergency', 'Gynecology', 'Oncology', 'Psychiatry', 'General Medicine',
         'Radiology', 'Urology', 'Gastroenterology', 'ENT', 'Nephrology'
     ] AS dept_names) AS depts;

	 -- ALTER the table to remove UNIQUE constraint
ALTER TABLE departments DROP CONSTRAINT departments_name_key;

select * from departments

CREATE TABLE treatments (
    id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(id) ON DELETE CASCADE,
    doctor_id INT REFERENCES doctors(id) ON DELETE SET NULL,
    appointment_id INT REFERENCES appointments(id) ON DELETE SET NULL,
    treatment_name VARCHAR(100) NOT NULL,
    treatment_type VARCHAR(50),  -- e.g., Surgical, Medication, Therapy
    treatment_date DATE NOT NULL,
    notes TEXT,
    cost NUMERIC(10, 2),
    status VARCHAR(20) CHECK (status IN ('Ongoing', 'Completed', 'Cancelled')) DEFAULT 'Ongoing'
);

select * from treatments

INSERT INTO treatments (
    patient_id,
    doctor_id,
    appointment_id,
    treatment_name,
    treatment_type,
    treatment_date,
    notes,
    cost,
    status
)
SELECT
    (i % 500) + 1,  -- patient_id between 1–500
    (i % 100) + 1,  -- doctor_id between 1–100
    (i % 500) + 1,  -- appointment_id between 1–500
    treatments[i % array_length(treatments, 1) + 1],
    types[i % array_length(types, 1) + 1],
    CURRENT_DATE - ((i * 3) % 365),  -- random treatment_date within last year
    'Treatment notes for patient ' || (i % 500) + 1,
    ROUND((random() * 1000 + 5000)::NUMERIC, 2),  -- cost between 5000–6000
    CASE
        WHEN i % 10 = 0 THEN 'Cancelled'
        WHEN i % 3 = 0 THEN 'Completed'
        ELSE 'Ongoing'
    END
FROM generate_series(1, 500) AS s(i),
     (SELECT ARRAY[
         'Physiotherapy', 'Chemotherapy', 'Dialysis', 'Fracture Fixation', 
         'Root Canal', 'Vaccination', 'Blood Transfusion', 'MRI Scan', 
         'CT Scan', 'Cataract Surgery'
     ] AS treatments) AS t,
     (SELECT ARRAY[
         'Therapy', 'Surgical', 'Medication', 'Diagnostic'
     ] AS types) AS tp;

--FIRST EXMAPLE INNER JOIN QUERRY--

select * from patients
select * from doctors

SELECT *
FROM patients
INNER JOIN doctors
ON patients.id = doctors.id; 
-- IN THE PATIENTS TABLE ID IS START FROM 2 AND IN DOCTORS TABLE ID IS START FROM 1 SO THE INNER JOIN QUERRY RETURNS THE SAME VALUES IN FROM BOTH TABLES ---

SELECT *
FROM patients
JOIN appointments ON patients.id = appointments.patient_id
JOIN doctors ON appointments.doctor_id = doctors.id
WHERE patients.gender = 'female';


select * from appointments

select * from departments

-- SECOND EXAMPLE OF RIGHT JOIN QUERRY--

SELECT *
FROM departments
RIGHT JOIN appointments
ON departments.id = appointments.patient_id; 

-- THIRD EXAMPLE OF LEFT JOIN QUERRY--


select * from treatments
select * from departments

SELECT * FROM treatments 
LEFT JOIN departments 
ON treatments. patient_id = departments.id;

--in this join full data shows from left table and returns similar data from right side--

-- FOURTH EXAMPLE OF OUTER JOIN QUERRY--

SELECT * FROM treatments 
FULL OUTER JOIN departments 
ON treatments. patient_id = departments.id;

-- IN THIS FULL OUTER JOIN RETURN TWO FULL TABLE WITH SIMILAR DATA--


--MULTI JOIN EXMAPLE--

select * from appointments
select * from patients
select * from doctors


SELECT 
    patients.first_name AS patient_name,
    appointments.appointment_date AS appointment_date,
    doctors.first_name AS doctor_name
FROM appointments
JOIN patients ON appointments.id = patients.id
JOIN doctors ON appointments.id = doctor_id;








