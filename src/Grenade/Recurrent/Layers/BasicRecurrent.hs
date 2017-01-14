{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE GADTs                 #-}
{-# LANGUAGE RecordWildCards       #-}
{-# LANGUAGE TypeOperators         #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE UndecidableInstances  #-}

-- GHC 7.10 doesn't see recurrent run functions as total.
{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}
module Grenade.Recurrent.Layers.BasicRecurrent (
    BasicRecurrent (..)
  , randomBasicRecurrent
  ) where



import           Control.Monad.Random ( MonadRandom, getRandom )

import           Data.Singletons.TypeLits

import           Numeric.LinearAlgebra.Static

import           GHC.TypeLits

import           Grenade.Core.Network
import           Grenade.Core.Shape
import           Grenade.Recurrent.Core.Network

data BasicRecurrent :: Nat -- Input layer size
                    -> Nat -- Output layer size
                    -> * where
  BasicRecurrent :: ( KnownNat input
                    , KnownNat output
                    , KnownNat matrixCols
                    , matrixCols ~ (input + output))
                 => !(R output)   -- Bias neuron weights
                 -> !(R output)   -- Bias neuron momentum
                 -> !(L output matrixCols) -- Activation
                 -> !(L output matrixCols) -- Momentum
                 -> BasicRecurrent input output

data BasicRecurrent' :: Nat -- Input layer size
                     -> Nat -- Output layer size
                     -> * where
  BasicRecurrent' :: ( KnownNat input
                     , KnownNat output
                     , KnownNat matrixCols
                     , matrixCols ~ (input + output))
                  => !(R output)   -- Bias neuron gradients
                  -> !(L output matrixCols)
                  -> BasicRecurrent' input output

instance Show (BasicRecurrent i o) where
  show BasicRecurrent {} = "BasicRecurrent"

instance (KnownNat i, KnownNat o, KnownNat (i + o)) => UpdateLayer (BasicRecurrent i o) where
  type Gradient (BasicRecurrent i o) = (BasicRecurrent' i o)

  runUpdate LearningParameters {..} (BasicRecurrent oldBias oldBiasMomentum oldActivations oldMomentum) (BasicRecurrent' biasGradient activationGradient) =
    let newBiasMomentum = konst learningMomentum * oldBiasMomentum - konst learningRate * biasGradient
        newBias         = oldBias + newBiasMomentum
        newMomentum     = konst learningMomentum * oldMomentum - konst learningRate * activationGradient
        regulariser     = konst (learningRegulariser * learningRate) * oldActivations
        newActivations  = oldActivations + newMomentum - regulariser
    in BasicRecurrent newBias newBiasMomentum newActivations newMomentum

  createRandom = randomBasicRecurrent

instance (KnownNat i, KnownNat o, KnownNat (i + o), i <= (i + o), o ~ ((i + o) - i)) => RecurrentUpdateLayer (BasicRecurrent i o) where
  type RecurrentShape (BasicRecurrent i o) = 'D1 o

instance (KnownNat i, KnownNat o, KnownNat (i + o), i <= (i + o), o ~ ((i + o) - i)) => RecurrentLayer (BasicRecurrent i o) ('D1 i) ('D1 o) where
  -- Do a matrix vector multiplication and return the result.
  runRecurrentForwards (BasicRecurrent wB _ wN _) (S1D lastOutput) (S1D thisInput) =
    let thisOutput = S1D $ wB + wN #> (thisInput # lastOutput)
    in (thisOutput, thisOutput)

  -- Run a backpropogation step for a full connected layer.
  runRecurrentBackwards (BasicRecurrent _ _ wN _) (S1D lastOutput) (S1D thisInput) (S1D dRec) (S1D dEdy) =
    let biasGradient        = (dRec + dEdy)
        layerGrad           = (dRec + dEdy) `outer` (thisInput # lastOutput)
        -- calcluate derivatives for next step
        (backGrad, recGrad) = split $ tr wN #> (dRec + dEdy)
    in  (BasicRecurrent' biasGradient layerGrad, S1D recGrad, S1D backGrad)

randomBasicRecurrent :: (MonadRandom m, KnownNat i, KnownNat o, KnownNat x, x ~ (i + o))
                     => m (BasicRecurrent i o)
randomBasicRecurrent = do
    seed1 <- getRandom
    seed2 <- getRandom
    let wB = randomVector seed1 Uniform * 2 - 1
        wN = uniformSample seed2 (-1) 1
        bm = konst 0
        mm = konst 0
    return $ BasicRecurrent wB bm wN mm
