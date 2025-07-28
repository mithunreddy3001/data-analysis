Problem 1: Comprehensive Library Report

-- 1. Books Not Loaned Out in the Last 6 Months
SELECT B.Title, A.FirstName, A.LastName
FROM Books B
JOIN Authors A ON B.AuthorID = A.AuthorID
WHERE B.BookID NOT IN (
    SELECT BookID FROM Loans
    WHERE LoanDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
);

-- 2. Top Members by Number of Books Borrowed in the Last Year
SELECT M.FirstName, M.LastName, COUNT(L.LoanID) AS BooksBorrowed, M.MembershipStartDate
FROM Members M
JOIN Loans L ON M.MemberID = L.MemberID
WHERE L.LoanDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY M.MemberID
ORDER BY BooksBorrowed DESC
LIMIT 5;

-- 3. Overdue Books Report
SELECT B.Title, M.FirstName, M.LastName, L.DueDate, DATEDIFF(CURDATE(), L.DueDate) AS DaysOverdue
FROM Loans L
JOIN Books B ON L.BookID = B.BookID
JOIN Members M ON L.MemberID = M.MemberID
WHERE L.Returned = FALSE AND L.DueDate < CURDATE()
ORDER BY DaysOverdue DESC;

-- 4. Top 3 Most Borrowed Categories
SELECT C.CategoryName, COUNT(BC.BookID) AS BorrowCount
FROM Categories C
JOIN BookCategories BC ON C.CategoryID = BC.CategoryID
JOIN Loans L ON BC.BookID = L.BookID
GROUP BY C.CategoryID
ORDER BY BorrowCount DESC
LIMIT 3;

-- 5. Are there any books Belonging to Multiple Categories
SELECT B.Title, COUNT(BC.CategoryID) AS CategoryCount
FROM Books B
JOIN BookCategories BC ON B.BookID = BC.BookID
GROUP BY B.BookID
HAVING CategoryCount > 1;

-- Problem 2: Advanced Library Data Analysis

-- 6. Average Number of Days Books Are Kept
SELECT ROUND(AVG(DATEDIFF(L.ReturnDate, L.LoanDate)), 2) AS AvgDaysKept
FROM Loans L
WHERE L.ReturnDate IS NOT NULL;

-- 7. Members with Reservations but No Loans in the Last Year
SELECT M.FirstName, M.LastName, B.Title
FROM Members M
JOIN Reservations R ON M.MemberID = R.MemberID
JOIN Books B ON R.BookID = B.BookID
WHERE M.MemberID NOT IN (
    SELECT MemberID FROM Loans WHERE LoanDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
);

-- 8. Percentage of Books Loaned Out per Category
SELECT C.CategoryName,
       ROUND((COUNT(L.BookID) / COUNT(BC.BookID)) * 100, 2) AS LoanPercentage
FROM Categories C
JOIN BookCategories BC ON C.CategoryID = BC.CategoryID
LEFT JOIN Loans L ON BC.BookID = L.BookID AND L.Returned = FALSE
GROUP BY C.CategoryID;

-- 9. Total Number of Loans and Reservations Per Member
SELECT M.FirstName, M.LastName,
       COUNT(L.LoanID) AS TotalLoans,
       COUNT(R.ReservationID) AS TotalReservations
FROM Members M
LEFT JOIN Loans L ON M.MemberID = L.MemberID
LEFT JOIN Reservations R ON M.MemberID = R.MemberID
GROUP BY M.MemberID
ORDER BY TotalLoans DESC, TotalReservations DESC;

-- Additional Challenging Questions

-- 10. Find Members Who Borrowed Books by the Same Author More Than Once
SELECT M.FirstName, M.LastName, A.FirstName AS AuthorFirstName, A.LastName AS AuthorLastName, COUNT(DISTINCT L.BookID) AS BooksByAuthor
FROM Members M
JOIN Loans L ON M.MemberID = L.MemberID
JOIN Books B ON L.BookID = B.BookID
JOIN Authors A ON B.AuthorID = A.AuthorID
GROUP BY M.MemberID, A.AuthorID
HAVING BooksByAuthor > 1;

-- 11. List Members Who Have Both Borrowed and Reserved the Same Book
SELECT M.FirstName, M.LastName, B.Title
FROM Members M
JOIN Loans L ON M.MemberID = L.MemberID
JOIN Reservations R ON M.MemberID = R.MemberID
JOIN Books B ON L.BookID = B.BookID AND R.BookID = B.BookID
GROUP BY M.MemberID, B.BookID;

-- 12. Books Loaned and Never Returned
SELECT B.Title, M.FirstName, M.LastName, L.LoanDate, L.DueDate
FROM Loans L
JOIN Books B ON L.BookID = B.BookID
JOIN Members M ON L.MemberID = M.MemberID
WHERE L.Returned = FALSE;

-- 13. Authors with the Most Borrowed Books
SELECT A.FirstName, A.LastName, COUNT(L.BookID) AS BorrowCount
FROM Authors A
JOIN Books B ON A.AuthorID = B.AuthorID
JOIN Loans L ON B.BookID = L.BookID
GROUP BY A.AuthorID
ORDER BY BorrowCount DESC
LIMIT 5;

-- 14. Books Borrowed by Members Who Joined in the Last 6 Months
SELECT B.Title, M.FirstName, M.LastName, M.MembershipStartDate
FROM Books B
JOIN Loans L ON B.BookID = L.BookID
JOIN Members M ON L.MemberID = M.MemberID
WHERE M.MembershipStartDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH);