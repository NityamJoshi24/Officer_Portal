// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_flow_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$LoginFlowState {
  LoginStep get step => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get selectedState => throw _privateConstructorUsedError;
  String? get userToken => throw _privateConstructorUsedError;

  /// Create a copy of LoginFlowState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginFlowStateCopyWith<LoginFlowState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginFlowStateCopyWith<$Res> {
  factory $LoginFlowStateCopyWith(
    LoginFlowState value,
    $Res Function(LoginFlowState) then,
  ) = _$LoginFlowStateCopyWithImpl<$Res, LoginFlowState>;
  @useResult
  $Res call({
    LoginStep step,
    bool isLoading,
    String? errorMessage,
    String? selectedState,
    String? userToken,
  });
}

/// @nodoc
class _$LoginFlowStateCopyWithImpl<$Res, $Val extends LoginFlowState>
    implements $LoginFlowStateCopyWith<$Res> {
  _$LoginFlowStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginFlowState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? step = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? selectedState = freezed,
    Object? userToken = freezed,
  }) {
    return _then(
      _value.copyWith(
            step: null == step
                ? _value.step
                : step // ignore: cast_nullable_to_non_nullable
                      as LoginStep,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            selectedState: freezed == selectedState
                ? _value.selectedState
                : selectedState // ignore: cast_nullable_to_non_nullable
                      as String?,
            userToken: freezed == userToken
                ? _value.userToken
                : userToken // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LoginFlowStateImplCopyWith<$Res>
    implements $LoginFlowStateCopyWith<$Res> {
  factory _$$LoginFlowStateImplCopyWith(
    _$LoginFlowStateImpl value,
    $Res Function(_$LoginFlowStateImpl) then,
  ) = __$$LoginFlowStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    LoginStep step,
    bool isLoading,
    String? errorMessage,
    String? selectedState,
    String? userToken,
  });
}

/// @nodoc
class __$$LoginFlowStateImplCopyWithImpl<$Res>
    extends _$LoginFlowStateCopyWithImpl<$Res, _$LoginFlowStateImpl>
    implements _$$LoginFlowStateImplCopyWith<$Res> {
  __$$LoginFlowStateImplCopyWithImpl(
    _$LoginFlowStateImpl _value,
    $Res Function(_$LoginFlowStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoginFlowState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? step = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? selectedState = freezed,
    Object? userToken = freezed,
  }) {
    return _then(
      _$LoginFlowStateImpl(
        step: null == step
            ? _value.step
            : step // ignore: cast_nullable_to_non_nullable
                  as LoginStep,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        selectedState: freezed == selectedState
            ? _value.selectedState
            : selectedState // ignore: cast_nullable_to_non_nullable
                  as String?,
        userToken: freezed == userToken
            ? _value.userToken
            : userToken // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$LoginFlowStateImpl extends _LoginFlowState {
  const _$LoginFlowStateImpl({
    this.step = LoginStep.mobilePassword,
    this.isLoading = false,
    this.errorMessage,
    this.selectedState,
    this.userToken,
  }) : super._();

  @override
  @JsonKey()
  final LoginStep step;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;
  @override
  final String? selectedState;
  @override
  final String? userToken;

  @override
  String toString() {
    return 'LoginFlowState(step: $step, isLoading: $isLoading, errorMessage: $errorMessage, selectedState: $selectedState, userToken: $userToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginFlowStateImpl &&
            (identical(other.step, step) || other.step == step) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.selectedState, selectedState) ||
                other.selectedState == selectedState) &&
            (identical(other.userToken, userToken) ||
                other.userToken == userToken));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    step,
    isLoading,
    errorMessage,
    selectedState,
    userToken,
  );

  /// Create a copy of LoginFlowState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginFlowStateImplCopyWith<_$LoginFlowStateImpl> get copyWith =>
      __$$LoginFlowStateImplCopyWithImpl<_$LoginFlowStateImpl>(
        this,
        _$identity,
      );
}

abstract class _LoginFlowState extends LoginFlowState {
  const factory _LoginFlowState({
    final LoginStep step,
    final bool isLoading,
    final String? errorMessage,
    final String? selectedState,
    final String? userToken,
  }) = _$LoginFlowStateImpl;
  const _LoginFlowState._() : super._();

  @override
  LoginStep get step;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;
  @override
  String? get selectedState;
  @override
  String? get userToken;

  /// Create a copy of LoginFlowState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginFlowStateImplCopyWith<_$LoginFlowStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
