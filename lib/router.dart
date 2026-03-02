 import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:threadly/features/auth/presentation/pages/login_page.dart';
import 'package:threadly/features/communities/presentation/create_community_page.dart';
import 'package:threadly/features/home/pages/home_page.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginPage()),
});

final loggedInRoute  = RouteMap(routes: {
  '/' : (_) => const MaterialPage(child: HomePage()),
  '/create-community' : (_) => const MaterialPage(child: CreateCommunityPage()),  
});