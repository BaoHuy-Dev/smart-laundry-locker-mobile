// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'locker.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Locker {

 int get id; int get storeId; String get name; String? get code; String? get location; String? get image; String? get imageUrl; LockerStatus get status; int get totalBoxes; int get availableBoxes; String? get createdAt; String? get updatedAt;
/// Create a copy of Locker
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LockerCopyWith<Locker> get copyWith => _$LockerCopyWithImpl<Locker>(this as Locker, _$identity);

  /// Serializes this Locker to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Locker&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.location, location) || other.location == location)&&(identical(other.image, image) || other.image == image)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalBoxes, totalBoxes) || other.totalBoxes == totalBoxes)&&(identical(other.availableBoxes, availableBoxes) || other.availableBoxes == availableBoxes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storeId,name,code,location,image,imageUrl,status,totalBoxes,availableBoxes,createdAt,updatedAt);

@override
String toString() {
  return 'Locker(id: $id, storeId: $storeId, name: $name, code: $code, location: $location, image: $image, imageUrl: $imageUrl, status: $status, totalBoxes: $totalBoxes, availableBoxes: $availableBoxes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $LockerCopyWith<$Res>  {
  factory $LockerCopyWith(Locker value, $Res Function(Locker) _then) = _$LockerCopyWithImpl;
@useResult
$Res call({
 int id, int storeId, String name, String? code, String? location, String? image, String? imageUrl, LockerStatus status, int totalBoxes, int availableBoxes, String? createdAt, String? updatedAt
});




}
/// @nodoc
class _$LockerCopyWithImpl<$Res>
    implements $LockerCopyWith<$Res> {
  _$LockerCopyWithImpl(this._self, this._then);

  final Locker _self;
  final $Res Function(Locker) _then;

/// Create a copy of Locker
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeId = null,Object? name = null,Object? code = freezed,Object? location = freezed,Object? image = freezed,Object? imageUrl = freezed,Object? status = null,Object? totalBoxes = null,Object? availableBoxes = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LockerStatus,totalBoxes: null == totalBoxes ? _self.totalBoxes : totalBoxes // ignore: cast_nullable_to_non_nullable
as int,availableBoxes: null == availableBoxes ? _self.availableBoxes : availableBoxes // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Locker].
extension LockerPatterns on Locker {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Locker value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Locker() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Locker value)  $default,){
final _that = this;
switch (_that) {
case _Locker():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Locker value)?  $default,){
final _that = this;
switch (_that) {
case _Locker() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int storeId,  String name,  String? code,  String? location,  String? image,  String? imageUrl,  LockerStatus status,  int totalBoxes,  int availableBoxes,  String? createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Locker() when $default != null:
return $default(_that.id,_that.storeId,_that.name,_that.code,_that.location,_that.image,_that.imageUrl,_that.status,_that.totalBoxes,_that.availableBoxes,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int storeId,  String name,  String? code,  String? location,  String? image,  String? imageUrl,  LockerStatus status,  int totalBoxes,  int availableBoxes,  String? createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Locker():
return $default(_that.id,_that.storeId,_that.name,_that.code,_that.location,_that.image,_that.imageUrl,_that.status,_that.totalBoxes,_that.availableBoxes,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int storeId,  String name,  String? code,  String? location,  String? image,  String? imageUrl,  LockerStatus status,  int totalBoxes,  int availableBoxes,  String? createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Locker() when $default != null:
return $default(_that.id,_that.storeId,_that.name,_that.code,_that.location,_that.image,_that.imageUrl,_that.status,_that.totalBoxes,_that.availableBoxes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Locker implements Locker {
  const _Locker({required this.id, required this.storeId, required this.name, this.code, this.location, this.image, this.imageUrl, this.status = LockerStatus.active, this.totalBoxes = 0, this.availableBoxes = 0, this.createdAt, this.updatedAt});
  factory _Locker.fromJson(Map<String, dynamic> json) => _$LockerFromJson(json);

@override final  int id;
@override final  int storeId;
@override final  String name;
@override final  String? code;
@override final  String? location;
@override final  String? image;
@override final  String? imageUrl;
@override@JsonKey() final  LockerStatus status;
@override@JsonKey() final  int totalBoxes;
@override@JsonKey() final  int availableBoxes;
@override final  String? createdAt;
@override final  String? updatedAt;

/// Create a copy of Locker
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LockerCopyWith<_Locker> get copyWith => __$LockerCopyWithImpl<_Locker>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LockerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Locker&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.location, location) || other.location == location)&&(identical(other.image, image) || other.image == image)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalBoxes, totalBoxes) || other.totalBoxes == totalBoxes)&&(identical(other.availableBoxes, availableBoxes) || other.availableBoxes == availableBoxes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storeId,name,code,location,image,imageUrl,status,totalBoxes,availableBoxes,createdAt,updatedAt);

@override
String toString() {
  return 'Locker(id: $id, storeId: $storeId, name: $name, code: $code, location: $location, image: $image, imageUrl: $imageUrl, status: $status, totalBoxes: $totalBoxes, availableBoxes: $availableBoxes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$LockerCopyWith<$Res> implements $LockerCopyWith<$Res> {
  factory _$LockerCopyWith(_Locker value, $Res Function(_Locker) _then) = __$LockerCopyWithImpl;
@override @useResult
$Res call({
 int id, int storeId, String name, String? code, String? location, String? image, String? imageUrl, LockerStatus status, int totalBoxes, int availableBoxes, String? createdAt, String? updatedAt
});




}
/// @nodoc
class __$LockerCopyWithImpl<$Res>
    implements _$LockerCopyWith<$Res> {
  __$LockerCopyWithImpl(this._self, this._then);

  final _Locker _self;
  final $Res Function(_Locker) _then;

/// Create a copy of Locker
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeId = null,Object? name = null,Object? code = freezed,Object? location = freezed,Object? image = freezed,Object? imageUrl = freezed,Object? status = null,Object? totalBoxes = null,Object? availableBoxes = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Locker(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LockerStatus,totalBoxes: null == totalBoxes ? _self.totalBoxes : totalBoxes // ignore: cast_nullable_to_non_nullable
as int,availableBoxes: null == availableBoxes ? _self.availableBoxes : availableBoxes // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Box {

 int get id; int get lockerId; String get boxNumber; BoxSize get size; BoxStatus get status; String? get createdAt; String? get updatedAt;
/// Create a copy of Box
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoxCopyWith<Box> get copyWith => _$BoxCopyWithImpl<Box>(this as Box, _$identity);

  /// Serializes this Box to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Box&&(identical(other.id, id) || other.id == id)&&(identical(other.lockerId, lockerId) || other.lockerId == lockerId)&&(identical(other.boxNumber, boxNumber) || other.boxNumber == boxNumber)&&(identical(other.size, size) || other.size == size)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,lockerId,boxNumber,size,status,createdAt,updatedAt);

@override
String toString() {
  return 'Box(id: $id, lockerId: $lockerId, boxNumber: $boxNumber, size: $size, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BoxCopyWith<$Res>  {
  factory $BoxCopyWith(Box value, $Res Function(Box) _then) = _$BoxCopyWithImpl;
@useResult
$Res call({
 int id, int lockerId, String boxNumber, BoxSize size, BoxStatus status, String? createdAt, String? updatedAt
});




}
/// @nodoc
class _$BoxCopyWithImpl<$Res>
    implements $BoxCopyWith<$Res> {
  _$BoxCopyWithImpl(this._self, this._then);

  final Box _self;
  final $Res Function(Box) _then;

/// Create a copy of Box
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? lockerId = null,Object? boxNumber = null,Object? size = null,Object? status = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,lockerId: null == lockerId ? _self.lockerId : lockerId // ignore: cast_nullable_to_non_nullable
as int,boxNumber: null == boxNumber ? _self.boxNumber : boxNumber // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as BoxSize,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BoxStatus,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Box].
extension BoxPatterns on Box {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Box value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Box() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Box value)  $default,){
final _that = this;
switch (_that) {
case _Box():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Box value)?  $default,){
final _that = this;
switch (_that) {
case _Box() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int lockerId,  String boxNumber,  BoxSize size,  BoxStatus status,  String? createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Box() when $default != null:
return $default(_that.id,_that.lockerId,_that.boxNumber,_that.size,_that.status,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int lockerId,  String boxNumber,  BoxSize size,  BoxStatus status,  String? createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Box():
return $default(_that.id,_that.lockerId,_that.boxNumber,_that.size,_that.status,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int lockerId,  String boxNumber,  BoxSize size,  BoxStatus status,  String? createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Box() when $default != null:
return $default(_that.id,_that.lockerId,_that.boxNumber,_that.size,_that.status,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Box implements Box {
  const _Box({required this.id, required this.lockerId, required this.boxNumber, required this.size, this.status = BoxStatus.available, this.createdAt, this.updatedAt});
  factory _Box.fromJson(Map<String, dynamic> json) => _$BoxFromJson(json);

@override final  int id;
@override final  int lockerId;
@override final  String boxNumber;
@override final  BoxSize size;
@override@JsonKey() final  BoxStatus status;
@override final  String? createdAt;
@override final  String? updatedAt;

/// Create a copy of Box
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoxCopyWith<_Box> get copyWith => __$BoxCopyWithImpl<_Box>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BoxToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Box&&(identical(other.id, id) || other.id == id)&&(identical(other.lockerId, lockerId) || other.lockerId == lockerId)&&(identical(other.boxNumber, boxNumber) || other.boxNumber == boxNumber)&&(identical(other.size, size) || other.size == size)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,lockerId,boxNumber,size,status,createdAt,updatedAt);

@override
String toString() {
  return 'Box(id: $id, lockerId: $lockerId, boxNumber: $boxNumber, size: $size, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BoxCopyWith<$Res> implements $BoxCopyWith<$Res> {
  factory _$BoxCopyWith(_Box value, $Res Function(_Box) _then) = __$BoxCopyWithImpl;
@override @useResult
$Res call({
 int id, int lockerId, String boxNumber, BoxSize size, BoxStatus status, String? createdAt, String? updatedAt
});




}
/// @nodoc
class __$BoxCopyWithImpl<$Res>
    implements _$BoxCopyWith<$Res> {
  __$BoxCopyWithImpl(this._self, this._then);

  final _Box _self;
  final $Res Function(_Box) _then;

/// Create a copy of Box
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? lockerId = null,Object? boxNumber = null,Object? size = null,Object? status = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Box(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,lockerId: null == lockerId ? _self.lockerId : lockerId // ignore: cast_nullable_to_non_nullable
as int,boxNumber: null == boxNumber ? _self.boxNumber : boxNumber // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as BoxSize,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BoxStatus,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$LockerReport {

 int get id; int get userId; int get lockerId; String get description; LockerReportStatus get status; String get createdAt; String? get resolvedAt;
/// Create a copy of LockerReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LockerReportCopyWith<LockerReport> get copyWith => _$LockerReportCopyWithImpl<LockerReport>(this as LockerReport, _$identity);

  /// Serializes this LockerReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LockerReport&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.lockerId, lockerId) || other.lockerId == lockerId)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,lockerId,description,status,createdAt,resolvedAt);

@override
String toString() {
  return 'LockerReport(id: $id, userId: $userId, lockerId: $lockerId, description: $description, status: $status, createdAt: $createdAt, resolvedAt: $resolvedAt)';
}


}

/// @nodoc
abstract mixin class $LockerReportCopyWith<$Res>  {
  factory $LockerReportCopyWith(LockerReport value, $Res Function(LockerReport) _then) = _$LockerReportCopyWithImpl;
@useResult
$Res call({
 int id, int userId, int lockerId, String description, LockerReportStatus status, String createdAt, String? resolvedAt
});




}
/// @nodoc
class _$LockerReportCopyWithImpl<$Res>
    implements $LockerReportCopyWith<$Res> {
  _$LockerReportCopyWithImpl(this._self, this._then);

  final LockerReport _self;
  final $Res Function(LockerReport) _then;

/// Create a copy of LockerReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? lockerId = null,Object? description = null,Object? status = null,Object? createdAt = null,Object? resolvedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,lockerId: null == lockerId ? _self.lockerId : lockerId // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LockerReportStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LockerReport].
extension LockerReportPatterns on LockerReport {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LockerReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LockerReport() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LockerReport value)  $default,){
final _that = this;
switch (_that) {
case _LockerReport():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LockerReport value)?  $default,){
final _that = this;
switch (_that) {
case _LockerReport() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int userId,  int lockerId,  String description,  LockerReportStatus status,  String createdAt,  String? resolvedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LockerReport() when $default != null:
return $default(_that.id,_that.userId,_that.lockerId,_that.description,_that.status,_that.createdAt,_that.resolvedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int userId,  int lockerId,  String description,  LockerReportStatus status,  String createdAt,  String? resolvedAt)  $default,) {final _that = this;
switch (_that) {
case _LockerReport():
return $default(_that.id,_that.userId,_that.lockerId,_that.description,_that.status,_that.createdAt,_that.resolvedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int userId,  int lockerId,  String description,  LockerReportStatus status,  String createdAt,  String? resolvedAt)?  $default,) {final _that = this;
switch (_that) {
case _LockerReport() when $default != null:
return $default(_that.id,_that.userId,_that.lockerId,_that.description,_that.status,_that.createdAt,_that.resolvedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LockerReport implements LockerReport {
  const _LockerReport({required this.id, required this.userId, required this.lockerId, required this.description, this.status = LockerReportStatus.pending, required this.createdAt, this.resolvedAt});
  factory _LockerReport.fromJson(Map<String, dynamic> json) => _$LockerReportFromJson(json);

@override final  int id;
@override final  int userId;
@override final  int lockerId;
@override final  String description;
@override@JsonKey() final  LockerReportStatus status;
@override final  String createdAt;
@override final  String? resolvedAt;

/// Create a copy of LockerReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LockerReportCopyWith<_LockerReport> get copyWith => __$LockerReportCopyWithImpl<_LockerReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LockerReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LockerReport&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.lockerId, lockerId) || other.lockerId == lockerId)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,lockerId,description,status,createdAt,resolvedAt);

@override
String toString() {
  return 'LockerReport(id: $id, userId: $userId, lockerId: $lockerId, description: $description, status: $status, createdAt: $createdAt, resolvedAt: $resolvedAt)';
}


}

/// @nodoc
abstract mixin class _$LockerReportCopyWith<$Res> implements $LockerReportCopyWith<$Res> {
  factory _$LockerReportCopyWith(_LockerReport value, $Res Function(_LockerReport) _then) = __$LockerReportCopyWithImpl;
@override @useResult
$Res call({
 int id, int userId, int lockerId, String description, LockerReportStatus status, String createdAt, String? resolvedAt
});




}
/// @nodoc
class __$LockerReportCopyWithImpl<$Res>
    implements _$LockerReportCopyWith<$Res> {
  __$LockerReportCopyWithImpl(this._self, this._then);

  final _LockerReport _self;
  final $Res Function(_LockerReport) _then;

/// Create a copy of LockerReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? lockerId = null,Object? description = null,Object? status = null,Object? createdAt = null,Object? resolvedAt = freezed,}) {
  return _then(_LockerReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,lockerId: null == lockerId ? _self.lockerId : lockerId // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LockerReportStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
