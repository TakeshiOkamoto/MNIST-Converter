#
# Editor 2018 Takeshi Okamoto
#
# Original file
# https://github.com/tensorflow/tensorflow/blob/master/tensorflow/contrib/learn/python/learn/datasets/mnist.py
# ==============================================================================
# Copyright 2016 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import numpy
from six.moves import xrange  # pylint: disable=redefined-builtin

from tensorflow.python.framework import dtypes
from tensorflow.python.framework import random_seed
import collections

Datasets = collections.namedtuple('Datasets', ['train', 'validation', 'test'])

def _read32(bytestream):
  dt = numpy.dtype(numpy.uint32).newbyteorder('>')
  return numpy.frombuffer(bytestream.read(4), dtype=dt)[0]

def extract_images(f):
  """Extract the images into a 4D uint8 numpy array [index, y, x, depth].

  Args:
    f: A file object that can be passed into a gzip reader.

  Returns:
    data: A 4D uint8 numpy array [index, y, x, depth].

  Raises:
    ValueError: If the bytestream does not start with 2051.

  """
  print('Extracting', f.name)
  magic = _read32(f)
  if magic != 2051:
    raise ValueError('Invalid magic number %d in MNIST image file: %s' %
                   (magic, f.name))
  num_images = _read32(f)
  rows = _read32(f)
  cols = _read32(f)
  buf = f.read(rows * cols * num_images)
  data = numpy.frombuffer(buf, dtype=numpy.uint8)
  data = data.reshape(num_images, rows, cols, 1)
  return data

def dense_to_one_hot(labels_dense, num_classes):
  """Convert class labels from scalars to one-hot vectors."""
  
  num_labels = labels_dense.shape[0]
  labels_one_hot = numpy.zeros((num_labels, num_classes))
  
  for i in range(num_labels):
    labels_one_hot[i][labels_dense[i]] = 1
    
  return labels_one_hot

def extract_labels(f, num_classes, one_hot=False):

  print('Extracting', f.name)
  magic = _read32(f)
  num_items = _read32(f)
  
  # normal  
  if magic == 2049:
    buf = f.read(num_items)
    labels = numpy.frombuffer(buf, dtype=numpy.uint8)    
    
  # expansion  
  elif magic == 2050:
    dt = numpy.dtype(numpy.uint16).newbyteorder('>')
    buf = f.read(num_items * 2)
    labels = numpy.frombuffer(buf, dtype=dt)
  else: 
    raise ValueError('Invalid magic number %d in MNIST label file: %s' %
                     (magic, f.name))       
  
  # range check
  for i in range(num_items):
    if (labels[i] > (num_classes-1)):
      raise ValueError('MNIST Label Error(%s): Please set label to 0-%d, because number of classes is %d.' %
                   (f.name, num_classes-1, num_classes)) 
    
  if one_hot:
    return dense_to_one_hot(labels, num_classes)
  return labels

class DataSet(object):

  def __init__(self,
               images,
               labels,
               fake_data=False,
               one_hot=False,
               dtype=dtypes.float32,
               reshape=True,
               seed=None):
    """Construct a DataSet.
    one_hot arg is used only if fake_data is true.  `dtype` can be either
    `uint8` to leave the input as `[0, 255]`, or `float32` to rescale into
    `[0, 1]`.  Seed arg provides for convenient deterministic testing.
    """
    seed1, seed2 = random_seed.get_seed(seed)
    # If op level seed is not set, use whatever graph level seed is returned
    numpy.random.seed(seed1 if seed is None else seed2)
    dtype = dtypes.as_dtype(dtype).base_dtype
    if dtype not in (dtypes.uint8, dtypes.float32):
      raise TypeError(
          'Invalid image dtype %r, expected uint8 or float32' % dtype)
          
    if fake_data:
      self._num_examples = 10000
      self.one_hot = one_hot
    else:
      assert images.shape[0] == labels.shape[0], (
          'images.shape: %s labels.shape: %s' % (images.shape, labels.shape))
      self._num_examples = images.shape[0]

      # Convert shape from [num examples, rows, columns, depth]
      # to [num examples, rows*columns] (assuming depth == 1)
      if reshape:
        assert images.shape[3] == 1
        images = images.reshape(images.shape[0],
                                images.shape[1] * images.shape[2])
      if dtype == dtypes.float32:
        # Convert from [0, 255] -> [0.0, 1.0].
        images = images.astype(numpy.float32)
        images = numpy.multiply(images, 1.0 / 255.0)
    self._images = images
    self._labels = labels
    self._epochs_completed = 0
    self._index_in_epoch = 0

  @property
  def images(self):
    return self._images

  @property
  def labels(self):
    return self._labels

  @property
  def num_examples(self):
    return self._num_examples

  @property
  def epochs_completed(self):
    return self._epochs_completed

  def next_batch(self, batch_size, shuffle=True):
    """Return the next `batch_size` examples from this data set."""

    start = self._index_in_epoch
    # Shuffle for the first epoch
    if self._epochs_completed == 0 and start == 0 and shuffle:
      perm0 = numpy.arange(self._num_examples)
      numpy.random.shuffle(perm0)
      self._images = self.images[perm0]
      self._labels = self.labels[perm0]
    # Go to the next epoch
    if start + batch_size > self._num_examples:
      # Finished epoch
      self._epochs_completed += 1
      # Get the rest examples in this epoch
      rest_num_examples = self._num_examples - start
      images_rest_part = self._images[start:self._num_examples]
      labels_rest_part = self._labels[start:self._num_examples]
      # Shuffle the data
      if shuffle:
        perm = numpy.arange(self._num_examples)
        numpy.random.shuffle(perm)
        self._images = self.images[perm]
        self._labels = self.labels[perm]
      # Start next epoch
      start = 0
      self._index_in_epoch = batch_size - rest_num_examples
      end = self._index_in_epoch
      images_new_part = self._images[start:end]
      labels_new_part = self._labels[start:end]
      return numpy.concatenate(
          (images_rest_part, images_new_part), axis=0), numpy.concatenate(
              (labels_rest_part, labels_new_part), axis=0)
    else:
      self._index_in_epoch += batch_size
      end = self._index_in_epoch
      return self._images[start:end], self._labels[start:end]

def read_data_sets(train_images_file,
                   train_labels_file,
                   test_images_file,
                   test_labels_file,
                   validation_size,
                   num_classes,
                   one_hot=False,
                   dtype=dtypes.float32,
                   reshape=True,
                   seed=None
                   ):

  # 各ファイルの読み込み                                   
  with open(train_images_file, 'rb') as f:
    train_images = extract_images(f)

  with open(train_labels_file, 'rb') as f:
    train_labels = extract_labels(f, num_classes, one_hot=one_hot)

  with open(test_images_file, 'rb') as f:
    test_images = extract_images(f)

  with open(test_labels_file, 'rb') as f:
    test_labels = extract_labels(f, num_classes, one_hot=one_hot)

  if not 0 <= validation_size <= len(train_images):
    raise ValueError('Validation size should be between 0 and {}. Received: {}.'
                     .format(len(train_images), validation_size))

  validation_images = train_images[:validation_size]
  validation_labels = train_labels[:validation_size]
  train_images = train_images[validation_size:]
  train_labels = train_labels[validation_size:]

  options = dict(dtype=dtype, reshape=reshape, seed=seed)

  train = DataSet(train_images, train_labels, **options)
  validation = DataSet(validation_images, validation_labels, **options)
  test = DataSet(test_images, test_labels, **options)

  return Datasets(train=train, validation=validation, test=test)
