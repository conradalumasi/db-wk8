-- Create the library database
CREATE DATABASE IF NOT EXISTS library_management_system;
USE library_management_system;
CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE,
    address VARCHAR(255) NOT NULL,
    membership_date DATE NOT NULL,
    membership_status ENUM('Active', 'Suspended', 'Expired') DEFAULT 'Active',
    CONSTRAINT chk_email_format CHECK (email LIKE '%@%.%')
);
CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    isbn VARCHAR(13) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(100) NOT NULL,
    publisher VARCHAR(100),
    publication_year YEAR,
    genre VARCHAR(50),
    total_copies INT NOT NULL DEFAULT 1,
    available_copies INT NOT NULL DEFAULT 1,
    location VARCHAR(50),
    CONSTRAINT chk_copies CHECK (
        available_copies <= total_copies
        AND available_copies >= 0
    ),
    CONSTRAINT chk_isbn_length CHECK (LENGTH(isbn) IN (10, 13))
);
CREATE TABLE borrowing_transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    late_fee DECIMAL(5, 2) DEFAULT 0.00,
    status ENUM('Borrowed', 'Returned', 'Overdue') DEFAULT 'Borrowed',
    CONSTRAINT fk_transaction_book FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    CONSTRAINT fk_transaction_member FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    CONSTRAINT chk_dates CHECK (
        due_date > borrow_date
        AND (
            return_date IS NULL
            OR return_date >= borrow_date
        )
    )
);
CREATE TABLE staff (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE,
    position VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10, 2),
    supervisor_id INT NULL,
    CONSTRAINT fk_staff_supervisor FOREIGN KEY (supervisor_id) REFERENCES staff(staff_id) ON DELETE
    SET NULL,
        CONSTRAINT chk_salary_positive CHECK (salary > 0)
);
CREATE TABLE authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    author_name VARCHAR(100) NOT NULL,
    nationality VARCHAR(50),
    birth_year YEAR
);
-- Junction table for Books-Authors Many-to-Many relationship
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_book_authors_book FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    CONSTRAINT fk_book_authors_author FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);
CREATE TABLE reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    status ENUM('Pending', 'Confirmed', 'Cancelled') DEFAULT 'Pending',
    expiry_date DATE NOT NULL,
    CONSTRAINT fk_reservation_book FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    CONSTRAINT fk_reservation_member FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    CONSTRAINT chk_reservation_expiry CHECK (expiry_date > reservation_date)
);
CREATE TABLE fines (
    fine_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    amount DECIMAL(6, 2) NOT NULL,
    fine_date DATE NOT NULL,
    reason VARCHAR(255),
    paid_date DATE,
    status ENUM('Unpaid', 'Paid') DEFAULT 'Unpaid',
    CONSTRAINT fk_fine_member FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    CONSTRAINT chk_fine_amount CHECK (amount >= 0)
);
-- Insert sample members
INSERT INTO members (
        first_name,
        last_name,
        email,
        phone,
        address,
        membership_date
    )
VALUES (
        'John',
        'Doe',
        'john.doe@email.com',
        '123-456-7890',
        '123 Main St',
        '2024-01-15'
    ),
    (
        'Jane',
        'Smith',
        'jane.smith@email.com',
        '234-567-8901',
        '456 Oak Ave',
        '2024-02-20'
    );
-- Insert sample books
INSERT INTO books (
        isbn,
        title,
        author,
        publisher,
        publication_year,
        total_copies
    )
VALUES (
        '978-0451524935',
        '1984',
        'George Orwell',
        'Signet Classics',
        1949,
        5
    ),
    (
        '978-0743273565',
        'The Great Gatsby',
        'F. Scott Fitzgerald',
        'Scribner',
        1925,
        3
    );
-- Insert sample borrowing transaction
INSERT INTO borrowing_transactions (book_id, member_id, borrow_date, due_date)
VALUES (1, 1, '2024-10-01', '2024-10-15');
-- Create indexes for frequently queried columns
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_author ON books(author);
CREATE INDEX idx_members_email ON members(email);
CREATE INDEX idx_transactions_status ON borrowing_transactions(status);
CREATE INDEX idx_transactions_due_date ON borrowing_transactions(due_date);