// Error de aplicación con código HTTP. Lo captura el middleware de errores.
export class AppError extends Error {
  status: number;
  code: string;
  details?: unknown;

  constructor(status: number, code: string, message: string, details?: unknown) {
    super(message);
    this.status = status;
    this.code = code;
    this.details = details;
  }

  static badRequest(message = "Solicitud inválida", details?: unknown) {
    return new AppError(400, "bad_request", message, details);
  }
  static unauthorized(message = "No autenticado") {
    return new AppError(401, "unauthorized", message);
  }
  static forbidden(message = "Sin permiso") {
    return new AppError(403, "forbidden", message);
  }
  static notFound(message = "No encontrado") {
    return new AppError(404, "not_found", message);
  }
  static conflict(message = "Conflicto") {
    return new AppError(409, "conflict", message);
  }
}
