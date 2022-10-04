-- Exercise

-- Define a function max3 :: Int -> Int -> Int -> (Int,Int,Int) that
-- orders the three inputs, e.g., max3 2 1 4 == (1,2,4) and 
-- max3 5 1 3 == (1,3,5)

max3 :: Int -> Int -> Int -> (Int,Int,Int)
max3 x y z
    | x >= y && x >= z = if y > z then (x, y, z) else (x, z, y)
    | x <= y && x <= z = if y > z then (y, z, x) else (z, y, x)
    | otherwise = if y > z then (y, x, z) else (z, x, y)

-- Write a function isSorted using recursion and pattern matching
-- that checks whether a given list of integers is sorted, e.g.
-- isSorted [1,2,3,3,5,6] == True and isSorted [1,2,4,3,5,6] == False

isSorted :: [Int] -> Bool
isSorted [] = True
isSorted [x] = True
isSorted (x: y: xs)
    | x <= y = isSorted(y: xs)
    | otherwise = False

-- A triple (x,y,z) of positive integers is called pythagorenian if
-- x^2 + y^2 == z^2. Using list comprehension, define a function 
-- pyths :: Int -> [(Int,Int,Int)] that returns the list of all 
-- pythagorenian triples whose components are less or equal the given
-- limit, e.g., pyths 10 == [(3,4,5),(4,3,5),(6,8,10),(8,6,10)]

pyths :: Int -> [(Int,Int,Int)]
pyths n = [(x, y, z) | x <- [1..n], y <- [1..n], z <- [1..n], x^2 + y^2 == z^2]

-- Write a function sqrAll1 :: [Int] -> [Int] that squares all numbers in
-- a list using list comprehesion, e.g., sqrAll1 [1,2,3] == [1,4,9]

sqrAll1 :: [Int] -> [Int]
sqrAll1 k = [n^2 | n <- k]

-- Rewrite the function of the previous question using map.
-- Call this definition sqrAll2.

sqrAll2 :: [Int] -> [Int]
sqrAll2 k = map (^2) k

-- Write a function noMultiples1 using recursion and pattern matching
-- that returns for a given integer x and list l the list of all elements 
-- in l that are not multiples of x, e.g., noMultiples1 1 [1,2,4,3,5,6]
-- == [] and noMultiples1 2 [1,2,4,3,5,6] == [1,3,5]

noMultiples1 :: Int -> [Int] -> [Int]
noMultiples1 n [] = []
noMultiples1 n (x: xs)
    | x `mod` n == 0 = noMultiples1 n xs
    | otherwise = x: noMultiples1 n xs
                      
-- Rewrite the function of the previous question using list comprehension.
-- Call this definition noMultiples2.

noMultiples2 :: Int -> [Int] -> [Int]
noMultiples2 n x = [k | k <- x, k `mod` n /= 0]

-- Rewrite the function of the previous question using foldr. Call this 
-- definition noMultiples3.

noMultiples3 :: Int -> [Int] -> [Int]
noMultiples3 x = foldr (\y r -> if y `mod` x == 0 then r else y:r) [] -- Ask professor

-- Write a function sub n l that subtracts all values from the list l from n
-- using foldl, e.g., sub 10 [1,2,3] == 4

sub :: Int -> [Int] -> Int
sub = foldl (-)

-- Write a function dec2Int :: [Int] -> Int that converts a list of digits 
-- (Int value from 0 to 9) into its corresponding Int using foldl, e.g., 
-- dec2Int [2,3,4,5] == 2345

dec2Int :: [Int] -> Int
dec2Int = foldl (\r d -> 10*r+d) 0

-- Write a function app that appends two lists using foldr.

app :: [a] -> [a] -> [a]
app xs ys = foldr (:) ys xs