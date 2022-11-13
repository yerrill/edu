{-
Question 1:
a) Implement a data type TruthValues as an enumeration type that contains
   the three "truth" values Yes, Unknown, and No.
b) Implement three functions tv_and :: TruthValues -> TruthValues -> TruthValues,
   tv_or :: TruthValues -> TruthValues -> TruthValues, and 
   tv_neg :: TruthValues -> TruthValues that compute an "and", "or", and "negation"
   for TruthValues following the tables below.

    tv_and  | Yes     | Unknown | No
    --------------------------------------
    Yes     | Yes     | Unknown | No
    Unknown | Unknown | Unknown | No
    No      | No      | No      | No

    tv_or   | Yes     | Unknown | No
    --------------------------------------
    Yes     | Yes     | Yes     | Yes
    Unknown | Yes     | Unknown | Unknown
    No      | Yes     | Unkown  | No

            | tv_neg 
    ------------------
    Yes     | No
    Unknown | Unknown
    No      | Yes   
    
c) Implement a new data type for rough sets. A rough set is a set that for any given
   element indicates that the element is either in the set, not in the set, or that it
   is unknown whether the element is in the set or not. Use a function a -> TruthValues
   to implement a rough set. Make sure that you use data and not type.
d) Implement universal, empty, complement, intersection, and union for rough sets similar
   to the second test but based on tv_and, tv_or, and tv_neg instead of &&, ||, and not.
e) Implement a function upper :: RoughSet a -> RoughSet a for which an element is in the
   set upper s iff it is in s or it is unknown, i.e, s x == Yes or s x == Unknown.
f) Implement a function lower :: RoughSet a -> RoughSet a for which an element is not in the
   set lower s iff it is not in s or it is unknown, i.e, s x == No or s x == Unknown.
-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use camelCase" #-}

data TruthValues = Yes | Unknown | No deriving (Eq, Show)

tv_and :: TruthValues -> TruthValues -> TruthValues
tv_and Yes Yes = Yes
tv_and Yes Unknown = Unknown
tv_and Unknown Unknown = Unknown
tv_and No _ = No
tv_and x y = tv_and y x 

tv_or :: TruthValues -> TruthValues -> TruthValues
tv_or Yes _ = Yes
tv_or Unknown _ = Unknown
tv_or No No = No
tv_or x y = tv_or y x

tv_neg :: TruthValues -> TruthValues
tv_neg Yes = No
tv_neg No = Yes
tv_neg Unknown = Unknown

data RoughSet a = RS (a -> TruthValues)

universal :: RoughSet a
universal = RS (const Yes)

empty :: RoughSet a
empty = RS (const No)

complement :: RoughSet a -> RoughSet a
complement (RS f) = RS (tv_neg . f)

intersection :: RoughSet a -> RoughSet a -> RoughSet a
intersection (RS f) (RS g) = RS (\x -> tv_and (f x) (g x))

union :: RoughSet a -> RoughSet a -> RoughSet a
union (RS f) (RS g) = RS (\x -> tv_or (f x) (g x))

upper :: RoughSet a -> RoughSet a
upper (RS s) = RS (\x -> if s x == No then No else Yes)

lower :: RoughSet a -> RoughSet a
lower (RS s) = RS (\x -> if s x == Yes then Yes else No)

{- 
Question 2:
a) Define a data type Expr of arithmetic expression made up from int's, variables (string),
   addition of two expressions, and multiplication of two expressions.
b) Make Expr an instance of Show so that expressions are printed as strings with the appropriate
   brackets according to ususal binding conventions of multiplication and addition, i.e., 
   an expression where 1 is multiplied by 2, and then 3 is added, should be printed as 1 * 2 + 3,
   and an expression where 1 is added to 2, and then multiplied by 3, should be printed as (1 + 2) * 3.
c) Use the type Env below of lookup table for values for variables to implement a function
   eval :: Env -> Expr -> Int that computes the value of an expression. For example, if the expression
   is (x + 3) * 2 and the environment [("x",4)] then eval should result in 14. You may want to use
   the functions maybe and lookup in the variable case.
-}

type Env = [(String,Int)] 

{- 
Question 3:
Below you find the data type Tree a of binary trees with empty leaves storing elements of type a at
inner nodes. Appropriate show and height functions are already implemented. In this question we want to
implement insertion and deletion in those trees as binary search trees resp. AVL trees (cf. Wikipedia
Binary search tree resp. AVL tree).
a) Define a function insert :: Ord a => a -> Tree a -> Tree a that inserts an element into a binary search
   tree at the appropriate position.
b) Implement a function removeLeftMost :: Tree a -> Maybe (a,Tree a) that returns for a tree t the pair
   consisting of the left-most element in the tree and the tree without that element (if those things 
   actally exists). For examples (+ denotes a leaf):
   
    removeLeftMost (Node 10 (Node 2 Leaf (Node 4 Leaf Leaf)) (Node 13 Leaf Leaf))
            = Just (2,Node 10 (Node 4 Leaf Leaf) (Node 13 Leaf Leaf))

       10                         10  
      /  \                       /  \
     2    13   ~~~>   2 and     4   13   
    + \  +  +                  + + +  +
       4
      + +
    
    removeLeftMost (Node 5 (Node 1 Leaf Leaf) (Node 6 Leaf Leaf))
            = Just (1,Node 5 Leaf (Node 6 Leaf Leaf))

       5                       5
      / \                     + \
     1   6   ~~~>    1 and       6 
    + + + +                     + +  
                  
    removeLeftMost Leaf = Nothing
    
c) Define a function delete :: Ord a => a -> Tree a -> Tree a that deletes an element from a binary 
   search tree. Use the function from b if you are at the node where the element that should be removed
   is stored.
d) Define a function balanceFactor :: Tree a -> Int that computes the balance factor of the root of the
   given tree. The balance factor is the difference of the height of the right and the left subtree.
e) Use d to define a function balanced :: Tree a -> Bool that checks whether the input tree is balanced.
   A tree is balanced if the absolut value of balance factor is smaller or equal to 1,i.e., the height of
   the left and right subtree differs by at most 1.
f) Implement for functions rotate_left, rotate_right, rotate_left_right, rotate_right_left :: Tree a -> Tree a
   which perform the correspnding rotation on the tree (cf. Wikipedia AVL tree).
g) Define a function balanceRoot :: Tree a -> Tree a that balances the root of the given tree using the 
   rotations from f. Here we assume that the balance factor of the root is in the range -2..2 and that all
   sbtrees are already balanced (cf. Wikipedia AVL tree).
h) Implement the function balance :: Tree a -> Tree a that balances a tree after insertion or deletion. Any
   leaf is already balanced and at an inner node apply the function from g after recursively balancing the 
   left and right subtree.
After implementing this question you can also test your program by call the function main() below (currently
commented). The program will does the same steps a the animated example on the Wikipedia page for AVL Trees.
-}

data Tree a = Leaf | Node a (Tree a) (Tree a)

showTree :: Show a => Int -> Tree a -> String
showTree n Leaf           = replicate n ' ' ++ "Leaf\n"
showTree n (Node a t1 t2) = replicate n ' ' ++ show a ++ "\n" ++ showTree (n+2) t1 ++ showTree (n+2) t2

instance Show a => Show (Tree a) where
  show t = showTree 0 t
  
height :: Tree a -> Int
height Leaf = 0
height (Node _ t1 t2) = 1+max (height t1) (height t2)


{-main :: IO ()
main = runExample ['m','n','o','l','k','q','p','h','i','a'] Leaf
    where runExample :: (Ord a, Show a) => [a] -> Tree a -> IO ()
          runExample [] t      = print t
          runExample (a:as) t  = do 
                                  print t
                                  putStrLn "Hit any key."
                                  getChar
                                  runExample as (insert a t)-}
              



