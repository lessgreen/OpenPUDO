/*
 OpenPUDO - PUDO and Micro-delivery software for Last Mile Collaboration
 Copyright (C) 2020-2022 LESS SRL - https://less.green

 This file is part of OpenPUDO software.

 OpenPUDO is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License version 3
 as published by the Copyright Owner.

 OpenPUDO is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License version 3 for more details.

 You should have received a copy of the GNU Affero General Public License
 version 3 published by the Copyright Owner along with OpenPUDO.  
 If not, see <https://github.com/lessgreen/OpenPUDO>.
*/

import 'package:stack_trace/stack_trace.dart';

extension TraceReflection on Trace {
  static List<String>? stackFrame([int index = 0]) {
    int stackFrame = 0;
    if (Trace.current().frames.length > index) {
      stackFrame = index;
    }
    return Trace.current()
        .frames[stackFrame]
        .member
        ?.replaceAll('.<fn>', '')
        .split('.')
        .map(
          (e) => (e.replaceFirst('_', '')),
        )
        .toList();
  }
}
