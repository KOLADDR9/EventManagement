import 'package:dartz/dartz.dart';
import 'package:event_management_app/core/error/failure.dart';

abstract class AuthRepository {
  Future<Either<Failure, bool>> login(String passcode);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, bool>> hasValidToken();
}
