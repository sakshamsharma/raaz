{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE TypeFamilies         #-}
{-# LANGUAGE ScopedTypeVariables  #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Raaz.Cipher.AES.CTR.Type where

import           Data.ByteString              (ByteString)
import qualified Data.ByteString              as BS
import           Foreign.Storable
import           Raaz.Primitives
import           Raaz.Primitives.Cipher
import           Raaz.Types
import           Raaz.Util.ByteString

import           Raaz.Cipher.AES.Internal


instance Primitive (Cipher AES k CTR e) where
  blockSize _ = cryptoCoerce $ BITS (8 :: Int)
  {-# INLINE blockSize #-}
  newtype IV (Cipher AES k CTR e) = AESIV (k, STATE)

instance EndianStore k => Initializable (Cipher AES k CTR e) where
  ivSize _ = BYTES (ksz + ssz)
    where
      ksz = sizeOf (undefined :: k)
      ssz = sizeOf (undefined :: STATE)
  {-# INLINE ivSize #-}
  getIV = AESIV . getIVCTR
    where
      getIVCTR bs = (k,fromByteString ivbs)
        where
          k = fromByteString kbs
          (kbs,ivbs) = BS.splitAt (sizeOf k) bs