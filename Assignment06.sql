--*************************************************************************--
-- Title: Assignment06
-- Author: J.R. Day
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2024-08-05,J.R. Day,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_JDay')
	 Begin 
	  Alter Database [Assignment06DB_JDay] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_JDay;
	 End
	Create Database Assignment06DB_JDay;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_JDay;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
go 

Create View vCategories 
With SchemaBinding
As 
Select CategoryID, CategoryName from dbo.Categories;
go 

Create View vProducts 
With SchemaBinding 
as 
Select ProductID, ProductName, CategoryID, UnitPrice from dbo.Products
go 
Select * from dbo.vProducts;
go

Create View vEmployees 
With SchemaBinding 
as 
Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID from dbo.Employees
go 
Select * from dbo.vEmployees;
go 

Create View vInventories 
with SchemaBinding 
as 
Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count] from dbo.Inventories
go
Select * from dbo.vInventories;

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
deny Select on dbo.Categories to Public;
Grant Select on dbo.vCategories to Public;

deny select on dbo.Products to Public;
grant select on dbo.vProducts to Public;

deny select on dbo.Employees to Public;
grant select on dbo.vEmployees to Public;

deny select on dbo.Inventories to Public;
grant select on dbo.vInventories to Public;

Select * from Categories; 
go 
Select * from vCategories;
go
-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
Create View vProductsByCategories 
With schemabinding
as 
select top 100 percent 
C.CategoryName, P.ProductName, P.UnitPrice from dbo.Categories as C join dbo.Products as p 
on C.CategoryID = P.CategoryID
Order by CategoryName, ProductName;
go
Select * from vProductsByCategories; 


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
Create view vInventoriesByProductsByDates
with Schemabinding
as 
select top 100 percent

P.ProductName, I.InventoryDate, I.[Count] from dbo.Products as P join dbo.Inventories as I on 
P.ProductID = I.ProductID
Order by ProductName, InventoryDate, [Count];
go
Select * from vInventoriesByProductsByDates;

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth
Create view vInventoriesByEmployeesByDates 
With schemabinding 
as 
Select distinct top 100 percent
I.InventoryDate, E.EmployeeFirstName + ' '+ E.EmployeeLastName as 'Employee Name' from dbo.Employees as E  join dbo.Inventories as I on 
E.EmployeeID = I.EmployeeID
order by I.InventoryDate;  
Select * from vInventoriesByEmployeesByDates
-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
go
Create view vInventoriesByProductsByCategories
with schemabinding
as 
Select top 100 percent C.CategoryName, P.ProductName, I.InventoryDate, I.[Count] from dbo.Inventories as I join dbo.Products as P 
on I.ProductID = P.ProductID
join dbo.Categories as C on P.CategoryID = C.CategoryID
Order by C.CategoryName, P.ProductID, I.InventoryDate, I.[Count];
Select * from vInventoriesByProductsByCategories
-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
go
Create view vInventoriesByProductsByEmployees 
with schemabinding 
as 
Select top 100 percent 
C.CategoryName, P.ProductName, I.InventoryDate, I.[Count], E.EmployeeFirstName + ' '+ E.EmployeeLastName as 'EmployeeName' from dbo.Inventories as I 
Join dbo.Products as P on P.ProductID = I.ProductID
Join dbo.Categories as C on C.CategoryID = P.CategoryID
Join dbo.Employees as E on E.EmployeeID = I.EmployeeID
Order by I.InventoryDate, C.CategoryName, P.ProductName, E.EmployeeLastName;
select * from vInventoriesByProductsByEmployees
-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
go
Create view vInventoriesForChaiAndChangByEmployees
with schemabinding 
as 
Select top 100 percent
C.CategoryName, P.ProductName, I.InventoryDate, I.[Count], E.EmployeeFirstName +' '+E.EmployeeLastName as 'Employee Name' from 
dbo.Inventories as I join dbo.Products as P on P.ProductID = I.ProductID
join dbo.Categories as C on C.CategoryID = P.CategoryID
join dbo.Employees as E on  E.EmployeeID = I.EmployeeID
Where P.ProductID in ( Select P.ProductID From dbo.Products as P 
						where P.ProductName In ('Chai', 'Chang'))
Order by I.InventoryDate, C.CategoryName, P.ProductName;
Select * from vInventoriesForChaiAndChangByEmployees

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
Create view vEmployeesByManager
with SchemaBinding 
as 
select top 100 percent  E.EmployeeFirstName + ' ' + E.EmployeeLastName as 'Employees',
M.EmployeeFirstName + ' ' + M.EmployeeLastName as 'Managers' from dbo.Employees as E join 
dbo.Employees as M on M.EmployeeID = E.ManagerID
order by E.ManagerID; 
select * from vEmployeesByManager

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
go

create View vInventoriesByProductsByCategoriesByEmployees
With Schemabinding 
as 
Select top 100 Percent
C.CategoryID, C.CategoryName, 
P.ProductID, P.ProductName, P.UnitPrice,
I.InventoryID, I.InventoryDate, I.[Count]
,E.EmployeeID, E.EmployeeFirstName, E.EmployeeLastName, E.ManagerID 
from dbo.Categories as C join dbo.Products as P on 
C.CategoryID = P.CategoryID
join dbo.Inventories as I on I.ProductID = P.ProductID
join dbo.Employees as E on E.EmployeeID = I.EmployeeID
order by CategoryName, ProductName, InventoryID, EmployeeFirstName, EmployeeLastName;
go
Select * from vInventoriesByProductsByCategoriesByEmployees;

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/