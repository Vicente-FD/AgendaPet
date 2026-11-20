import type { Request, Response } from "express";
import * as authService from "./auth.service";

export async function register(req: Request, res: Response) {
  const result = await authService.registerEmail(req.body);
  res.status(201).json(result);
}

export async function login(req: Request, res: Response) {
  const result = await authService.loginEmail(req.body);
  res.json(result);
}

export async function google(req: Request, res: Response) {
  const result = await authService.loginWithGoogle(req.body.idToken);
  res.json(result);
}

export async function apple(req: Request, res: Response) {
  const result = await authService.loginWithApple(
    req.body.identityToken,
    req.body.name,
  );
  res.json(result);
}

export async function refresh(req: Request, res: Response) {
  const result = await authService.refresh(req.body.refreshToken);
  res.json(result);
}

export async function logout(req: Request, res: Response) {
  await authService.logout(req.body.refreshToken);
  res.status(204).send();
}

export async function me(req: Request, res: Response) {
  const user = await authService.getMe(req.userId!);
  res.json({ user });
}
