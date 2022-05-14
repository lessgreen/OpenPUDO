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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/commons/utilities/network_error_helper.dart';
import 'package:qui_green/models/base_response.dart';
import 'package:qui_green/models/extra_info.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/models/registration_pudo_model.dart';
import 'package:qui_green/models/reward_option.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/current_user.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/commons/utilities/localization.dart';

class RewardPolicyControllerViewModel extends ChangeNotifier {
  RewardPolicyControllerViewModel(BuildContext context) {
    NetworkManager.instance.getPudoRewardSchema().then((value) {
      if (value is List<RewardOption>) {
        dataSource = value;
      } else {
        SAAlertDialog.displayAlertWithClose(
          context,
          'genericErrorTitle'.localized(context, 'general'),
          'unknownDescription'.localized(context, 'general'),
        );
      }
    }).catchError(
      (error) => SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), error),
    );
  }

  // ************ Navigation *****
  onSendClick(BuildContext context, RegistrationPudoModel requestModel) {
    NetworkManager.instance.registerPudo(requestModel.copyWith(rewardPolicy: dataSource)).then((value) {
      if (value != null && value is OPBaseResponse) {
        if (value.returnCode == 0) {
          if (requestModel.profilePic != null) {
            NetworkManager.instance.photoUpload(requestModel.profilePic!, isPudo: true).catchError(
                  (onError) => SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), onError),
                );
          }
          NetworkManager.instance.getMyPudoProfile().then((profile) {
            if (profile is PudoProfile) {
              Provider.of<CurrentUser>(context, listen: false).pudoProfile = profile;
              Navigator.of(context).pushReplacementNamed(
                Routes.pudoRegistrationPreview,
                arguments: requestModel.copyWith(rewardPolicy: dataSource),
              );
            } else {
              NetworkErrorHelper.helper(context, value);
            }
          }).catchError(
            (onError) => SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), onError),
          );
        } else {
          NetworkErrorHelper.helper(context, value);
        }
      } else {
        NetworkErrorHelper.helper(context, value);
      }
    }).catchError(
      (onError) => SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), onError),
    );
  }

  List<RewardOption> _dataSource = [];

  List<RewardOption> get dataSource => _dataSource;

  set dataSource(List<RewardOption> newVal) {
    _dataSource = newVal;
    notifyListeners();
  }

  bool get mandatoryFulfilled {
    for (var aRow in dataSource) {
      if ((aRow.checked ?? false) && aRow.extraInfo != null && aRow.extraInfo!.mandatoryValue == true) {
        switch (aRow.extraInfo!.type) {
          case ExtraInfoType.text:
            if (aRow.extraInfo!.value == null) {
              return false;
            }
            break;
          case ExtraInfoType.decimal:
            if (aRow.extraInfo!.value == null) {
              return false;
            }
            break;
          case ExtraInfoType.select:
            if (aRow.extraInfo!.values == null) {
              return true;
            } else {
              for (var anOption in aRow.extraInfo!.values!) {
                if (anOption.checked == true) {
                  return true;
                }
              }
              return false;
            }
        }
      }
    }
    return true;
  }

  bool get isExclusiveSelected {
    for (var aRow in dataSource) {
      if ((aRow.exclusive ?? false) && (aRow.checked ?? false)) {
        return true;
      }
    }
    return false;
  }

  void onValueChange(int index, bool value) {
    if (isExclusiveSelected) {
      if (dataSource[index].exclusive == false) {
        return;
      }
    }
    if (dataSource[index].exclusive ?? false) {
      for (int i = 0; i < dataSource.length; i++) {
        if (i == index) {
          dataSource[index].checked = value;
        } else {
          dataSource[i].checked = false;
        }
      }
    } else {
      dataSource[index].checked = value;
    }
    notifyListeners();
  }

  void onSubSelectValueChange(int rowIndex, int optionIndex, bool value) {
    int length = dataSource[rowIndex].extraInfo?.values?.length ?? 0;
    for (int i = 0; i < length; i++) {
      if (i == optionIndex) {
        dataSource[rowIndex].extraInfo?.values?[optionIndex].checked = value;
      } else {
        dataSource[rowIndex].extraInfo?.values?[i].checked = false;
      }
    }
    notifyListeners();
  }

  void onTextChange(int index, String value) {
    RewardOption? aRow = (index < dataSource.length) ? dataSource[index] : null;
    if (aRow == null || aRow.extraInfo == null) {
      return;
    }
    if (aRow.extraInfo!.type == ExtraInfoType.text || aRow.extraInfo!.type == ExtraInfoType.decimal) {
      aRow.extraInfo!.value = value;
      notifyListeners();
    }
  }

  void onSubTextChange(int rowIndex, int optionIndex, String value) {
    RewardOption? aRow = (rowIndex < dataSource.length) ? dataSource[rowIndex] : null;
    if (aRow == null || aRow.extraInfo == null) {
      return;
    }

    if (aRow.extraInfo == null || aRow.extraInfo!.values == null || optionIndex >= aRow.extraInfo!.values!.length) {
      return;
    }
    ExtraInfoSelectItem? subItem = aRow.extraInfo?.values?[optionIndex];
    if (subItem == null) {
      return;
    }
    if (subItem.extraInfo!.type == ExtraInfoType.text || subItem.extraInfo!.type == ExtraInfoType.decimal) {
      subItem.extraInfo!.value = value;
      notifyListeners();
    }
  }

  bool checkExtraInfo(ExtraInfo? info) {
    if (info != null) {
      switch (info.type) {
        case ExtraInfoType.text:
          if (info.value != null) {
            if ((info.value as String).isNotEmpty) {
              return true;
            }
          }
          break;
        case ExtraInfoType.decimal:
          if (info.value != null) {
            if ((info.value as String) != "0") {
              return true;
            }
          }
          break;
        case ExtraInfoType.select:
          if (info.values != null) {
            if (info.values is List<ExtraInfoSelectItem>) {
              for (ExtraInfoSelectItem item in info.values!) {
                if (item.checked ?? false) {
                  if (item.extraInfo != null) {
                    return checkExtraInfo(item.extraInfo);
                  } else {
                    return true;
                  }
                }
              }
            }
          }
      }
      return false;
    } else {
      return false;
    }
  }

  bool checkIfOptionIsValid(RewardOption option) {
    if (option.checked ?? false) {
      if (option.extraInfo != null) {
        if (checkExtraInfo(option.extraInfo)) {
          return true;
        }
      } else {
        return true;
      }
    }
    return false;
  }
}
