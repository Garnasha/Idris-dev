module Effect.StdIO

import Effects
import Control.IOExcept

-------------------------------------------------------------
-- IO effects internals
-------------------------------------------------------------

||| The internal representation of StdIO effects
data StdIO : Effect where
     PutStr : String -> { () } StdIO ()
     GetStr : { () } StdIO String
     PutCh : Char -> { () } StdIO ()
     GetCh : { () } StdIO Char


-------------------------------------------------------------
-- IO effects handlers
-------------------------------------------------------------

instance Handler StdIO IO where
    handle () (PutStr s) k = do putStr s; k () ()
    handle () GetStr     k = do x <- getLine; k x ()
    handle () (PutCh c)  k = do putChar c; k () ()
    handle () GetCh      k = do x <- getChar; k x ()

instance Handler StdIO (IOExcept a) where
    handle () (PutStr s) k = do ioe_lift $ putStr s; k () ()
    handle () GetStr     k = do x <- ioe_lift $ getLine; k x ()
    handle () (PutCh c)  k = do ioe_lift $ putChar c; k () ()
    handle () GetCh      k = do x <- ioe_lift $ getChar; k x ()

-------------------------------------------------------------
--- The Effect and associated functions
-------------------------------------------------------------

STDIO : EFFECT
STDIO = MkEff () StdIO

||| Write a string to standard output.
putStr : String -> { [STDIO] } Eff ()
putStr s = call $ PutStr s

||| Write a string to standard output, terminating with a newline.
putStrLn : String -> { [STDIO] } Eff ()
putStrLn s = putStr (s ++ "\n")

||| Write a character to standard output.
putChar : Char -> { [STDIO] } Eff ()
putChar c = call $ PutCh c

||| Write a character to standard output, terminating with a newline.
putCharLn : Char -> { [STDIO] } Eff ()
putCharLn c = putStrLn (singleton c)

||| Read a string from standard input.
getStr : { [STDIO] } Eff String
getStr = call $ GetStr

||| Read a character from standard input.
getChar : { [STDIO] } Eff Char
getChar = call $ GetCh

||| Given a parameter `a` 'show' `a` to standard output.
print : Show a => a -> { [STDIO] } Eff ()
print a = putStr (show a)

||| Given a parameter `a` 'show' `a` to a standard output, terminating with a newline
printLn : Show a => a -> { [STDIO] } Eff ()
printLn a = putStrLn (show a)
