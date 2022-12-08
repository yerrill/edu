{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use when" #-}
import Data.Maybe(isJust,fromJust)

{- 
   Exam Review
   
   For all functions you implement you must provide a type declaration.
   Some important functions, classes, and types:
   
   class  Monad m  where
       (>>=)       :: m a -> (a -> m b) -> m b
       return      :: a -> m a

   putStrLn :: String -> IO ()
     Write a string to the standard output device and add a newline character. 
     
   getLine :: IO String
     Read a line from the standard input device.   
     
   maybe :: b -> (a -> b) -> Maybe a -> b
     The maybe function takes a default value, a function, and a Maybe value. 
     If the Maybe value is Nothing, the function returns the default value. 
     Otherwise, it applies the function to the value inside the Just and returns 
     the result. 
     
   isJust :: Maybe a -> Bool
     The isJust function returns True iff its argument is of the form Just _. 
     
   fromJust :: Maybe a -> a
     The fromJust function extracts the element out of a Just and throws an 
     error if its argument is Nothing. 
     
   data  Either a b  =  Left a | Right b
   
   const :: a -> b -> a
     Constant function. 
   
   either :: (a -> c) -> (b -> c) -> Either a b -> c
     Case analysis for the Either type. If the value is Left a, apply the first 
     function to a; if it is Right b, apply the second function to b. 
   
   zip :: [a] -> [b] -> [(a, b)]
     zip takes two lists and returns a list of corresponding pairs. If 
     one input list is short, excess elements of the longer list are 
     discarded. 
   
   zipWith :: (a -> b -> c) -> [a] -> [b] -> [c]
     zipWith generalises zip by zipping with the function given as the first 
     argument, instead of a tupling function. For example, zipWith (+) is 
     applied to two lists to produce the list of corresponding sums. 
     
   (!!) :: [a] -> Int -> a
     List index (subscript) operator, starting from 0.
     
   reverse :: [a] -> [a]
     reverse xs returns the elements of xs in reverse order. xs must be finite. 
     
   read :: Read a => String -> a
     The read function reads input from a string, which must be completely 
     consumed by the input process. 
-}

{- 
   Question 1:
   a) Write an infinite list pf type [Integer] of all factorial numbers 
      [1,1,2,6,24,120,720,5040,40320,362880,3628800,39916800,...
      using the function zipWith. Therefore, notice that the list
      start with 1 and that we have
         1,2,3,4 ,5  ,6  ,7   ,... list [1..]
         1,1,2,6 ,24 ,120,720 ,... factorial
         1,2,6,24,120,720,5040,... zipWith (*) of the lists above gives
                                   tail of factorial 
   b) Write a function factorial :: Int -> Integer that returns the n
      factorial using the infinite list from a).
-}

factorials :: [Integer]
factorials = 1 : zipWith (*) [1..] factorials

factorial :: Int -> Integer
factorial = (factorials !!)


{-
   Question 2:
   a) Write a function lookupOrd similar to lookup that will always terminate
      (even for infinite lists) assuming that the keys (of type a) in the lookup
      table (of type [(a,b)]) are ordered (increasing).
      Examples:
      lookupOrd 4 (zip [1..] [2..])   = Just 5
      lookupOrd 4 (zip [1,3..] [2..]) = Nothing
   b) Use lookupOrd and the infinite list of factorials in order to implement a
      function invFactorial :: Integer -> Maybe Int so that the factorial of 
      invFactorial n (assuming a "Just result") is n.
      Examples:
      invFactorial 720 = Just 6
      invFactorial 24  = Just 4
      invFactorial 25  = Nothing
-}

lookupOrd :: Ord a => a -> [(a, b)] -> Maybe b
lookupOrd f ((k, v):ls)
    | f == k = Just v
    | f < k = Nothing
    | otherwise = lookupOrd f ls

invFactorial :: Integer -> Maybe Int
invFactorial n = lookupOrd n (zip factorials [0..])

{-
   Question 3:  
   a) Write an IO program myProg1 that reads a string from the input and prints
      the reversed string. Provide appropriate messages during the execution of
      the program.
   b) Write an IO program myProg2 that prompts for a list of integers
      (Haskell syntax) and prints the sum of the that list. Provide appropriate
      messages during the execution of the program.
   c) Write an IO program myProg3 that prompts for an integer. If the input is
      empty the program should terminate. Otherwise the program prints the 
      factorial of the number and starts over. Provide appropriate messages 
      during the execution of the program.
-}

myProg1 :: IO()
myProg1 = do
   putStrLn "Enter String:"
   line <- getLine
   let rev = reverse line
   putStrLn rev

myProg2 :: IO()
myProg2 = do
   putStrLn "Enter Number List:"
   input <- getLine
   let l :: [Int]
       l = read input
   putStrLn "Sum:"
   print (sum l)

myProg3 :: IO()
myProg3 = do
   putStrLn "Enter Integer:"
   line <- getLine
   if line /= "" then
      do
         let n :: Int
             n = read line
         putStrLn "Factorial:"
         print (factorial n)
         myProg3
   else return ()

             
{- 
   Question 4:
   Consider the following data type (see below) that represents results of 
   type a or an error message if the computation failed. There is also a
   function readError :: Read a => String -> Error a that works like read
   but instead of abandon execution if parsing fails it returns a element
   of the new Error type.
   a) Write a function mapError that applies a function f :: a -> b to an
      element of type Error a.
   b) Write a function catch :: Error a -> a -> a that catches an error in the
      first parameter by providing an error handler in the second parameter, i.e.,
      catch e x returns the element embedded in the first parameter e of type 
      Error a if no error has occurred, and returns the second parameter x if an 
      error has occurred.
   c) Make Error an instance of the class Monad.
   d) Write a function readInt :: IO Int that reads a string from the input
      and returns it as an Int. Use readError for parsing and catch for catching
      errors in parsing. The error handler should prompt the user again for
      a new input.
   e) Write a program myProg that uses readInt in order to accept an integer
      and then to print the integer with an appropriate message to the screen.
-}

data Error a = Result a | Error String

instance Functor Error where
  fmap f (Result x) = Result (f x)
  fmap f (Error s)  = Error s
  
instance Applicative Error where
  pure = Result
  (Result f) <*> x = fmap f x
  (Error s) <*> x  = Error s

readError :: Read a => String -> Error a
readError s = case [ x | (x,"") <- reads s ] of
                [x] -> Result x
                []  -> Error "Parsing error: no parse"
                _   -> Error "Parsing error: ambiguous parse"

mapError :: (a -> b) -> Error a -> Error b
mapError f (Result x) = Result (f x)
mapError _ (Error x) = Error x

catch :: Error a -> a -> a
catch (Result e) _ = e
catch (Error _) x = x

instance Monad Error where
   return :: a -> Error a
   return = Result
   (>>=) :: Error a -> (a -> Error b) -> Error b
   (Result x) >>= f = f x
   (Error x) >>= _ = Error x

readInt :: IO Int
readInt = do
   putStrLn "Enter Integer:"
   line <- getLine
   catch (mapError return (readError line)) readInt

myProg :: IO ()
myProg = do
   putStrLn "Enter Integer:"
   int <- readInt
   print int

{-
   Question 5:
   From Hoogle:
   mapMaybe :: (a -> Maybe b) -> [a] -> [b] 
   The mapMaybe function is a version of map which can throw out elements. In 
   particular, the functional argument returns something of type Maybe b. If 
   this is Nothing, no element is added on to the result list. If it just Just b, 
   then b is included in the result list.
   Example:
     mapMaybe (\x -> lookup x [(1,'a'),(2,'b')]) [0..4] = "ab"
   a) Implement mapMaybe a first time as mapMaybe1 using recursion and pattern 
      matching. You may find the function maybe (see above) useful.
   b) Implement mapMaybe a second time as mapMaybe2 using list comprehension. You 
      may find the functions isJust and fromJust (see above) useful.
   c) Implement mapMaybe a third time as mapMaybe3 using foldr. You may find the 
      function maybe (see above) useful again.
   d) Use one of the implementations of mapMaybe from a)-c) in order to implement
      a function collectLeft :: [Either a b] -> [a] that collects the elements of
      type a from the list of Either a b elements. You may find the function either
      (see above) useful.
      Examples:
        collectLeft [Left 1, Right "aa"] = [1]
        collectLeft [Left "Hello", Right 43, Left "World", Right 1, Right 666, Left "!"]
	      = ["Hello","World","!"]      
-}

mapMaybe1 :: (a -> Maybe b) -> [a] -> [b]
mapMaybe1 _ [] = []
mapMaybe1 f (x:xs) = maybe (mapMaybe1 f xs) (\x -> x:mapMaybe1 f xs) (f x)

mapMaybe2 :: (a -> Maybe b) -> [a] -> [b]
mapMaybe2 _ [] = []
mapMaybe2 f l = [fromJust z | x <- l, let z = f x, isJust z]

mapMaybe3 :: (a -> Maybe b) -> [a] -> [b]
mapMaybe3 f = foldr (\x y -> maybe y (:y) (f x)) []

{-
   Question 6:
   a) Implement a data type Tree a b of binary trees that store a elements
      at the leaves and b elements at the inner nodes.
      Example: of type Tree Int Char
          'a'
          / \
        'b'  2
        / \
       4   5
   b) Write a function collapse that collects the elements in a Tree a b as
      Either a b elements in a list. Use a depth first, pre-order traversal.
      Example:
        collapse "tree from a)" = [Right 'a',Right 'b',Left 4,Left 5,Left 2]
   c) Write a function eval that takes a tree of type Tree a (a->a->a),
      i.e., a tree with a elements at the leaves and binary functions at the
      nodes, and evaluates the tree. The evaluation of a leaf is the value
      stored at the leaf, and the evaluation of a node is the result of
      applying the function at the node to the evaluation of the two subtrees.
      Example: 
       tree :: Tree Int (Int -> Int -> Int)
       tree = Node (*) (Node (+) (Leaf 4) (Leaf 5)) (Leaf 2) 
       eval tree = 18
-}

data Tree a b = Leaf a | Node b (Tree a b) (Tree a b)

collapse :: Tree a b -> [Either a b]
collapse (Leaf a) = [Left a]
collapse (Node b l r) = Right b : collapse l ++ collapse r

eval :: Tree a (a -> a -> a) -> a
eval (Leaf a) = a
eval (Node f l r) = f (eval l) (eval r)

tree :: Tree Int (Int -> Int -> Int)
tree = Node (*) (Node (+) (Leaf 4) (Leaf 5)) (Leaf 2) 

{- 
   Question 7:
   Write a function construct :: [Either a b] -> (Tree a b,[Either a b])
   that produces a Tree a b out of an initial sequence of Either a b elements
   and returns that tree and the remaining sequence of Either a b elements. 
   You do not have to cover the case of an empty list as input.
   Examples:
     construct [Right 'a',Right 'b',Left 4,Left 5,Left 2] 
            = ("tree from Question 3a)",[])
     construct [Right 'a',Right 'b',Left 4,Left 5,Left 2,Right 'c',Left 0,Left 1]
            = ("tree from Question 3a)",[Right 'c',Left 0,Left 1])
     eval (fst (construct [Right (*),Right (+),Left 4,Left 5,Left 2])) = 18
-}     

construct :: [Either a b] -> (Tree a b,[Either a b])
construct ((Left a):xs) = (Leaf a, xs)
construct ((Right b):xs) = let
      (l, xs1) = construct xs
      (r, xs2) = construct xs1
      in (Node b l r, xs2)
