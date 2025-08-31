// Copyright 2025 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

class LibraryCapacity {
  final int occupancy;
  final int availableSeats;

  LibraryCapacity({required this.occupancy, required this.availableSeats});

  bool get isEmptyData => occupancy == 0 && availableSeats == 0;

  @override
  String toString() {
    return 'There are $occupancy people in the library '
        'with $availableSeats empty seat(s).';
  }
}
