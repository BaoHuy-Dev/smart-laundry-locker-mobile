// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Payment {

 int get id; int get orderId; double get amount; PaymentMethod get method; PaymentStatus get status; String? get transactionId; String? get paymentUrl; String? get expiredAt; String? get paidAt; String? get createdAt; String? get updatedAt;
/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentCopyWith<Payment> get copyWith => _$PaymentCopyWithImpl<Payment>(this as Payment, _$identity);

  /// Serializes this Payment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Payment&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.method, method) || other.method == method)&&(identical(other.status, status) || other.status == status)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.paymentUrl, paymentUrl) || other.paymentUrl == paymentUrl)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,amount,method,status,transactionId,paymentUrl,expiredAt,paidAt,createdAt,updatedAt);

@override
String toString() {
  return 'Payment(id: $id, orderId: $orderId, amount: $amount, method: $method, status: $status, transactionId: $transactionId, paymentUrl: $paymentUrl, expiredAt: $expiredAt, paidAt: $paidAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PaymentCopyWith<$Res>  {
  factory $PaymentCopyWith(Payment value, $Res Function(Payment) _then) = _$PaymentCopyWithImpl;
@useResult
$Res call({
 int id, int orderId, double amount, PaymentMethod method, PaymentStatus status, String? transactionId, String? paymentUrl, String? expiredAt, String? paidAt, String? createdAt, String? updatedAt
});




}
/// @nodoc
class _$PaymentCopyWithImpl<$Res>
    implements $PaymentCopyWith<$Res> {
  _$PaymentCopyWithImpl(this._self, this._then);

  final Payment _self;
  final $Res Function(Payment) _then;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderId = null,Object? amount = null,Object? method = null,Object? status = null,Object? transactionId = freezed,Object? paymentUrl = freezed,Object? expiredAt = freezed,Object? paidAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentStatus,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,paymentUrl: freezed == paymentUrl ? _self.paymentUrl : paymentUrl // ignore: cast_nullable_to_non_nullable
as String?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as String?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Payment].
extension PaymentPatterns on Payment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Payment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Payment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Payment value)  $default,){
final _that = this;
switch (_that) {
case _Payment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Payment value)?  $default,){
final _that = this;
switch (_that) {
case _Payment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int orderId,  double amount,  PaymentMethod method,  PaymentStatus status,  String? transactionId,  String? paymentUrl,  String? expiredAt,  String? paidAt,  String? createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Payment() when $default != null:
return $default(_that.id,_that.orderId,_that.amount,_that.method,_that.status,_that.transactionId,_that.paymentUrl,_that.expiredAt,_that.paidAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int orderId,  double amount,  PaymentMethod method,  PaymentStatus status,  String? transactionId,  String? paymentUrl,  String? expiredAt,  String? paidAt,  String? createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Payment():
return $default(_that.id,_that.orderId,_that.amount,_that.method,_that.status,_that.transactionId,_that.paymentUrl,_that.expiredAt,_that.paidAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int orderId,  double amount,  PaymentMethod method,  PaymentStatus status,  String? transactionId,  String? paymentUrl,  String? expiredAt,  String? paidAt,  String? createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Payment() when $default != null:
return $default(_that.id,_that.orderId,_that.amount,_that.method,_that.status,_that.transactionId,_that.paymentUrl,_that.expiredAt,_that.paidAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Payment implements Payment {
  const _Payment({required this.id, required this.orderId, required this.amount, required this.method, required this.status, this.transactionId, this.paymentUrl, this.expiredAt, this.paidAt, this.createdAt, this.updatedAt});
  factory _Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);

@override final  int id;
@override final  int orderId;
@override final  double amount;
@override final  PaymentMethod method;
@override final  PaymentStatus status;
@override final  String? transactionId;
@override final  String? paymentUrl;
@override final  String? expiredAt;
@override final  String? paidAt;
@override final  String? createdAt;
@override final  String? updatedAt;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentCopyWith<_Payment> get copyWith => __$PaymentCopyWithImpl<_Payment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Payment&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.method, method) || other.method == method)&&(identical(other.status, status) || other.status == status)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.paymentUrl, paymentUrl) || other.paymentUrl == paymentUrl)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,amount,method,status,transactionId,paymentUrl,expiredAt,paidAt,createdAt,updatedAt);

@override
String toString() {
  return 'Payment(id: $id, orderId: $orderId, amount: $amount, method: $method, status: $status, transactionId: $transactionId, paymentUrl: $paymentUrl, expiredAt: $expiredAt, paidAt: $paidAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PaymentCopyWith<$Res> implements $PaymentCopyWith<$Res> {
  factory _$PaymentCopyWith(_Payment value, $Res Function(_Payment) _then) = __$PaymentCopyWithImpl;
@override @useResult
$Res call({
 int id, int orderId, double amount, PaymentMethod method, PaymentStatus status, String? transactionId, String? paymentUrl, String? expiredAt, String? paidAt, String? createdAt, String? updatedAt
});




}
/// @nodoc
class __$PaymentCopyWithImpl<$Res>
    implements _$PaymentCopyWith<$Res> {
  __$PaymentCopyWithImpl(this._self, this._then);

  final _Payment _self;
  final $Res Function(_Payment) _then;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderId = null,Object? amount = null,Object? method = null,Object? status = null,Object? transactionId = freezed,Object? paymentUrl = freezed,Object? expiredAt = freezed,Object? paidAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Payment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentStatus,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,paymentUrl: freezed == paymentUrl ? _self.paymentUrl : paymentUrl // ignore: cast_nullable_to_non_nullable
as String?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as String?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RefundResponse {

 int get id; int get paymentId; int get orderId; double get amount; String get reason; RefundStatus get status; String? get rejectionReason; int? get processedBy; String get createdAt; String? get processedAt;
/// Create a copy of RefundResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefundResponseCopyWith<RefundResponse> get copyWith => _$RefundResponseCopyWithImpl<RefundResponse>(this as RefundResponse, _$identity);

  /// Serializes this RefundResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefundResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.processedBy, processedBy) || other.processedBy == processedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.processedAt, processedAt) || other.processedAt == processedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,paymentId,orderId,amount,reason,status,rejectionReason,processedBy,createdAt,processedAt);

@override
String toString() {
  return 'RefundResponse(id: $id, paymentId: $paymentId, orderId: $orderId, amount: $amount, reason: $reason, status: $status, rejectionReason: $rejectionReason, processedBy: $processedBy, createdAt: $createdAt, processedAt: $processedAt)';
}


}

/// @nodoc
abstract mixin class $RefundResponseCopyWith<$Res>  {
  factory $RefundResponseCopyWith(RefundResponse value, $Res Function(RefundResponse) _then) = _$RefundResponseCopyWithImpl;
@useResult
$Res call({
 int id, int paymentId, int orderId, double amount, String reason, RefundStatus status, String? rejectionReason, int? processedBy, String createdAt, String? processedAt
});




}
/// @nodoc
class _$RefundResponseCopyWithImpl<$Res>
    implements $RefundResponseCopyWith<$Res> {
  _$RefundResponseCopyWithImpl(this._self, this._then);

  final RefundResponse _self;
  final $Res Function(RefundResponse) _then;

/// Create a copy of RefundResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? paymentId = null,Object? orderId = null,Object? amount = null,Object? reason = null,Object? status = null,Object? rejectionReason = freezed,Object? processedBy = freezed,Object? createdAt = null,Object? processedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as int,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RefundStatus,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,processedBy: freezed == processedBy ? _self.processedBy : processedBy // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,processedAt: freezed == processedAt ? _self.processedAt : processedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RefundResponse].
extension RefundResponsePatterns on RefundResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RefundResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RefundResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RefundResponse value)  $default,){
final _that = this;
switch (_that) {
case _RefundResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RefundResponse value)?  $default,){
final _that = this;
switch (_that) {
case _RefundResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int paymentId,  int orderId,  double amount,  String reason,  RefundStatus status,  String? rejectionReason,  int? processedBy,  String createdAt,  String? processedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RefundResponse() when $default != null:
return $default(_that.id,_that.paymentId,_that.orderId,_that.amount,_that.reason,_that.status,_that.rejectionReason,_that.processedBy,_that.createdAt,_that.processedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int paymentId,  int orderId,  double amount,  String reason,  RefundStatus status,  String? rejectionReason,  int? processedBy,  String createdAt,  String? processedAt)  $default,) {final _that = this;
switch (_that) {
case _RefundResponse():
return $default(_that.id,_that.paymentId,_that.orderId,_that.amount,_that.reason,_that.status,_that.rejectionReason,_that.processedBy,_that.createdAt,_that.processedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int paymentId,  int orderId,  double amount,  String reason,  RefundStatus status,  String? rejectionReason,  int? processedBy,  String createdAt,  String? processedAt)?  $default,) {final _that = this;
switch (_that) {
case _RefundResponse() when $default != null:
return $default(_that.id,_that.paymentId,_that.orderId,_that.amount,_that.reason,_that.status,_that.rejectionReason,_that.processedBy,_that.createdAt,_that.processedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RefundResponse implements RefundResponse {
  const _RefundResponse({required this.id, required this.paymentId, required this.orderId, required this.amount, required this.reason, required this.status, this.rejectionReason, this.processedBy, required this.createdAt, this.processedAt});
  factory _RefundResponse.fromJson(Map<String, dynamic> json) => _$RefundResponseFromJson(json);

@override final  int id;
@override final  int paymentId;
@override final  int orderId;
@override final  double amount;
@override final  String reason;
@override final  RefundStatus status;
@override final  String? rejectionReason;
@override final  int? processedBy;
@override final  String createdAt;
@override final  String? processedAt;

/// Create a copy of RefundResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefundResponseCopyWith<_RefundResponse> get copyWith => __$RefundResponseCopyWithImpl<_RefundResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RefundResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefundResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.processedBy, processedBy) || other.processedBy == processedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.processedAt, processedAt) || other.processedAt == processedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,paymentId,orderId,amount,reason,status,rejectionReason,processedBy,createdAt,processedAt);

@override
String toString() {
  return 'RefundResponse(id: $id, paymentId: $paymentId, orderId: $orderId, amount: $amount, reason: $reason, status: $status, rejectionReason: $rejectionReason, processedBy: $processedBy, createdAt: $createdAt, processedAt: $processedAt)';
}


}

/// @nodoc
abstract mixin class _$RefundResponseCopyWith<$Res> implements $RefundResponseCopyWith<$Res> {
  factory _$RefundResponseCopyWith(_RefundResponse value, $Res Function(_RefundResponse) _then) = __$RefundResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, int paymentId, int orderId, double amount, String reason, RefundStatus status, String? rejectionReason, int? processedBy, String createdAt, String? processedAt
});




}
/// @nodoc
class __$RefundResponseCopyWithImpl<$Res>
    implements _$RefundResponseCopyWith<$Res> {
  __$RefundResponseCopyWithImpl(this._self, this._then);

  final _RefundResponse _self;
  final $Res Function(_RefundResponse) _then;

/// Create a copy of RefundResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? paymentId = null,Object? orderId = null,Object? amount = null,Object? reason = null,Object? status = null,Object? rejectionReason = freezed,Object? processedBy = freezed,Object? createdAt = null,Object? processedAt = freezed,}) {
  return _then(_RefundResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as int,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RefundStatus,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,processedBy: freezed == processedBy ? _self.processedBy : processedBy // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,processedAt: freezed == processedAt ? _self.processedAt : processedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
