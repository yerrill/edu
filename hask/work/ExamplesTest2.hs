import Prelude hiding (Monoid)

{- 
   Question 1:
   For this question do the following:
   a) Define a class Weighable that indicates that elements of a data type have some
      weight. A type is Weighable if:
      i) there is a function weight that assigns a Float to every element, 
      ii) there is a function weightDiff that computes the weight difference of two elements,
      iii) and there is an element zero of weight 0.0.
      Provide a default definition of weight in terms of weightDiff and vice versa.
   b) Make the data type Float an instance of Weighable so that the weight of number is its 
      absolute value.
   c) Make the data type of lists of a elements an instance of Weighable if the type a 
      already is. The empty list has weight 0.0 and the weight of a list is the sum of the
      weights of its elements.
      Examples:
      weight ([]::[Float]) = 0.0         (Notice the type annotations in the calls. They are
      weight ([1.1,2.3]::[Float]) = 3.4   necessary. Otherwise, the calls are ambiguous.)
   d) Write a function lighter that returns True if the first parameter is lighter, i.e., has
      a smaller weight, than the second parameter. The two parameters can be of different type
      as long as both are weighable.
      Example:
      lighter (5.0::Float) ([1.1,2.3]::[Float]) = False
-}

class Weighable a where
    weight :: a -> Float -- Definitions in terms of each other
    weightDiff :: a -> a -> Float
    zero :: a
    weightDiff x y = abs (weight x - weight y)
    weight x = weightDiff x zero

instance Weighable Float where
    zero = 0.0
    weight = abs

instance Weighable a => Weighable [a] where
    zero = [] -- Pattern matching?
    weight = sum . map weight

lighter :: (Weighable a, Weighable b) => a -> b -> Bool
lighter x y = weight x < weight y


{- 
   Question 2:
   For this question do the following:
   a) Define a class Monoid for monoids. A monoid is a data type that provides
      a binary operation (+++) and and element e. 
   b) Make the type Integer an instance of Monoid by using (+) and 0 as the 
      implementation of (+++) and e.
   c) Make the type of pairs (a,b) an instance of Monoid if a and b are already
      instances of Monoid. Define (+++) and e component-wise.
   d) Use foldl to write a function sumM that takes a list of Monoid elements and 
      produces their sum with respect to (+++), i.e.,
      sumM [a1,a2,...,an] = e +++ a1 +++ a2 +++ ... +++ an
      Examples:
      sumM [1..5] = 15
      sumM [(1,1),(2,3),(3,5),(4,7)] = (10,16)
   e) Use zipWith to write a function zipM that takes two lists of Monoid elements
      and produces a list of their corresponding sums with respect to (+++), i.e.,
      zipM [a1,a2,...,an] [b1,b2,...,bn] = [a1 +++ b1,a2 +++ b2,...,an +++ bn]
      Examples:
      zipM [1,2,3,4] [1,3,5,7] = [2,5,8,11]
      zipM [(1,1),(2,3),(3,5),(4,7)] [(1,1),(2,3),(3,5),(4,7)] = [(2,2),(4,6),(6,10),(8,14)]
-}

class Monoid a where
    (+++) :: a -> a -> a
    e :: a

instance Monoid Integer where
    (+++) = (+)
    e = 0

instance (Monoid a, Monoid b) => Monoid (a,b) where
    (x1, x2) +++ (y1, y2) = (x1 +++ y1, x2 +++ y2)
    e = (e, e)

sumM :: Monoid a => [a] -> a
sumM = foldl (+++) e

zipM :: Monoid a => [a] -> [a] -> [a]
zipM = zipWith (+++)


{-
   Question 3:
   For this question do the following:
   a) Define a class Listable for type constructors t that which allow to convert any element of 
      type t a to list of a elements. Name the corresponding member of the class, i.e., a function 
      t a -> [a] toList.
   b) Make the type constructor of lists, i.e., the type constructor [], an instance of Listable.
   c) Make the type constructor Maybe an instance of Listable. Note that elements of type Maybe a
      are either the element Nothing or Just x where x is from a. Nothing and Just can be used in 
      pattern matching.
   d) Write a function allT that for a given predicate p :: a -> Bool and an element of type t a
      where t is Listable returns True if all elements of type a in t a satisfy p.
   e) Write a function anyT that for a given predicate p :: a -> Bool and an element of type t a
      where t is Listable returns True if there is an element of type a in t a that satisfies p.            
-}

class Listable t where
    toList :: t a -> [a] 

instance Listable [] where
    toList = id

instance Listable Maybe where
    toList Nothing = []
    toList (Just x) = [x]

allT :: (Listable t) => (a -> Bool) -> t a -> Bool -- Look out for keywords because Haskell apparently has functions to do anything
allT p = all p . toList

anyT :: Listable t => (a -> Bool) -> t a -> Bool
anyT p = any p . toList
