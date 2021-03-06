{- |

Salsa20 is a stream cipher submitted to eSTREAM. Internally, the
cipher uses XOR, 32-bit addition, and constant-distance rotation
operations on an internal state of 16 32-bit words. This choice of
operations avoids the possibility of timing attacks in software
implementations.

Salsa20 with all the three variants of 20 rounds, 12 rounds and 8
rounds are implemented here.

-}
{-# LANGUAGE CPP #-}

module Raaz.Cipher.Salsa20
       ( Salsa20
       , KEY128
       , KEY256
       , Rounds(..)
       , Nonce
       , Counter
       , module Raaz.Core.Primitives
       , module Raaz.Core.Primitives.Cipher
       , HSalsa20Gadget, CSalsa20Gadget
       ) where

import Raaz.Core.Primitives
import Raaz.Core.Primitives.Cipher

import Raaz.Cipher.Salsa20.Instances
import Raaz.Cipher.Salsa20.Internal
