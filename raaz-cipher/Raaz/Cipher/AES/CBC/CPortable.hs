{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE FlexibleInstances        #-}
{-# LANGUAGE TypeFamilies             #-}
{-# OPTIONS_GHC -fno-warn-orphans     #-}

module Raaz.Cipher.AES.CBC.CPortable () where

import Foreign.Storable         (sizeOf)
import Raaz.Memory
import Raaz.Primitives
import Raaz.Primitives.Cipher
import Raaz.Types

import Raaz.Util.Ptr            (allocaBuffer)

import Raaz.Cipher.AES.CBC.Type
import Raaz.Cipher.AES.Ref.Type
import Raaz.Cipher.AES.Internal

foreign import ccall unsafe
  "raaz/cipher/cportable/aes.c raazCipherAESExpand"
  c_expand  :: CryptoPtr  -- ^ expanded key
            -> CryptoPtr  -- ^ key
            -> Int        -- ^ Key type
            -> IO ()

foreign import ccall unsafe
  "raaz/cipher/cportable/aes.c raazCipherAESCBCEncrypt"
  c_cbc_encrypt  :: CryptoPtr  -- ^ expanded key
                 -> CryptoPtr  -- ^ Input
                 -> CryptoPtr  -- ^ IV
                 -> Int        -- ^ Number of Blocks
                 -> Int        -- ^ Key type
                 -> IO ()

foreign import ccall unsafe
  "raaz/cipher/cportable/aes.c raazCipherAESCBCDecrypt"
  c_cbc_decrypt  :: CryptoPtr  -- ^ expanded key
                 -> CryptoPtr  -- ^ Input
                 -> CryptoPtr  -- ^ IV
                 -> Int        -- ^ Number of Blocks
                 -> Int        -- ^ Key type
                 -> IO ()

--------------------- AES128 ---------------------------------------------------

instance Gadget (CPortable128 CBC Encryption) where
  type PrimitiveOf (CPortable128 CBC Encryption) = AES128 CBC Encryption
  type MemoryOf (CPortable128 CBC Encryption) = (CryptoCell Expanded128, CryptoCell STATE)
  newGadgetWithMemory cc = return $ CPortable128 cc
  initialize (CPortable128 (ek,civ)) (AES128EIV (bs,iv)) =
    initialWith (ek,civ) (bs,iv) expand
   where
     expand kcptr ekcptr = c_expand ekcptr kcptr 0
  finalize _ = return AES128
  apply (CPortable128 (ek,civ)) n cptr = withCell ek (withCell civ . doStuff)
    where
      doStuff ekptr ivptr = c_cbc_encrypt ekptr cptr ivptr (fromIntegral n) 0

instance Gadget (CPortable128 CBC Decryption) where
  type PrimitiveOf (CPortable128 CBC Decryption) = AES128 CBC Decryption
  type MemoryOf (CPortable128 CBC Decryption) = (CryptoCell Expanded128, CryptoCell STATE)
  newGadgetWithMemory cc = return $ CPortable128 cc
  initialize (CPortable128 (ek,civ)) (AES128DIV (bs,iv)) =
    initialWith (ek,civ) (bs,iv) expand
   where
     expand kcptr ekcptr = c_expand ekcptr kcptr 0
  finalize _ = return AES128
  apply (CPortable128 (ek,civ)) n cptr = withCell ek (withCell civ . doStuff)
    where
      doStuff ekptr ivptr = c_cbc_decrypt ekptr cptr ivptr (fromIntegral n) 0


--------------------- AES192 ---------------------------------------------------

instance Gadget (CPortable192 CBC Encryption) where
  type PrimitiveOf (CPortable192 CBC Encryption) = AES192 CBC Encryption
  type MemoryOf (CPortable192 CBC Encryption) = (CryptoCell Expanded192, CryptoCell STATE)
  newGadgetWithMemory cc = return $ CPortable192 cc
  initialize (CPortable192 (ek,civ)) (AES192EIV (bs,iv)) =
    initialWith (ek,civ) (bs,iv) expand
   where
     expand kcptr ekcptr = c_expand ekcptr kcptr 1
  finalize _ = return AES192
  apply (CPortable192 (ek,civ)) n cptr = withCell ek (withCell civ . doStuff)
    where
      doStuff ekptr ivptr = c_cbc_encrypt ekptr cptr ivptr (fromIntegral n) 1

instance Gadget (CPortable192 CBC Decryption) where
  type PrimitiveOf (CPortable192 CBC Decryption) = AES192 CBC Decryption
  type MemoryOf (CPortable192 CBC Decryption) = (CryptoCell Expanded192, CryptoCell STATE)
  newGadgetWithMemory cc = return $ CPortable192 cc
  initialize (CPortable192 (ek,civ)) (AES192DIV (bs,iv)) =
    initialWith (ek,civ) (bs,iv) expand
   where
     expand kcptr ekcptr = c_expand ekcptr kcptr 1
  finalize _ = return AES192
  apply (CPortable192 (ek,civ)) n cptr = withCell ek (withCell civ . doStuff)
    where
      doStuff ekptr ivptr = c_cbc_decrypt ekptr cptr ivptr (fromIntegral n) 1


--------------------- AES256 ---------------------------------------------------

instance Gadget (CPortable256 CBC Encryption) where
  type PrimitiveOf (CPortable256 CBC Encryption) = AES256 CBC Encryption
  type MemoryOf (CPortable256 CBC Encryption) = (CryptoCell Expanded256, CryptoCell STATE)
  newGadgetWithMemory cc = return $ CPortable256 cc
  initialize (CPortable256 (ek,civ)) (AES256EIV (bs,iv)) =
    initialWith (ek,civ) (bs,iv) expand
   where
     expand kcptr ekcptr = c_expand ekcptr kcptr 2
  finalize _ = return AES256
  apply (CPortable256 (ek,civ)) n cptr = withCell ek (withCell civ . doStuff)
    where
      doStuff ekptr ivptr = c_cbc_encrypt ekptr cptr ivptr (fromIntegral n) 2

instance Gadget (CPortable256 CBC Decryption) where
  type PrimitiveOf (CPortable256 CBC Decryption) = AES256 CBC Decryption
  type MemoryOf (CPortable256 CBC Decryption) = (CryptoCell Expanded256, CryptoCell STATE)
  newGadgetWithMemory cc = return $ CPortable256 cc
  initialize (CPortable256 (ek,civ)) (AES256DIV (bs,iv)) =
    initialWith (ek,civ) (bs,iv) expand
   where
     expand kcptr ekcptr = c_expand ekcptr kcptr 2
  finalize _ = return AES256
  apply (CPortable256 (ek,civ)) n cptr = withCell ek (withCell civ . doStuff)
    where
      doStuff ekptr ivptr = c_cbc_decrypt ekptr cptr ivptr (fromIntegral n) 2


initialWith :: EndianStore k
            => (CryptoCell ek, CryptoCell STATE)
            -> (k, STATE)
            -> (CryptoPtr -> CryptoPtr -> IO ())
            -> IO ()
initialWith (ek,civ) (k,iv) with = allocaBuffer szk $ \kptr -> do
  store kptr k
  withCell ek $ with kptr
  withCell civ (flip store iv)
  where
    szk :: BYTES Int
    szk = BYTES $ sizeOf k
{-# INLINE initialWith #-}
