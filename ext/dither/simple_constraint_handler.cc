/*
 *
 * Copyright (C) 2015 Jason Gowan
 * All rights reserved.
 *
 * This software may be modified and distributed under the terms
 * of the BSD license.  See the LICENSE file for details.
 */

#include "simple_constraint_handler.h"
#include <iostream>

namespace dither {

  SimpleConstraintHandler::SimpleConstraintHandler(std::vector<dval>& ranges, std::vector<std::vector<dval>>& pconstraints) : params(ranges) {
    for(auto it = pconstraints.cbegin(); it != pconstraints.cend(); ++it) {
      std::vector<std::pair<std::size_t, dval>> constraint;
      std::size_t i = 0;
      for(auto iit = (*it).cbegin(); iit != (*it).cend(); ++iit, i++) {
        if((*iit) != -1) {
          constraint.push_back(std::make_pair(i, *iit));
        }
      }
      constraints.push_back(constraint);
    }
    std::sort(constraints.begin(), constraints.end(), [](std::vector<std::pair<std::size_t, dval>>& a, std::vector<std::pair<std::size_t, dval>>& b) { return a.size() < b.size(); });
  }

  bool SimpleConstraintHandler::violate_constraints(const dtest_case &test_case) {
    for(auto constraint = constraints.cbegin(); constraint != constraints.cend(); ++constraint) {
      if(violate_constraint(test_case, *constraint)) {
        return true;
      }
    }
    return false;
  }

  inline bool SimpleConstraintHandler::violate_constraint(const dtest_case& test_case, const std::vector<std::pair<std::size_t, dval>>& constraint) {
    for(auto it = constraint.cbegin(); it != constraint.cend(); ++it) {
      auto value = test_case[(*it).first];
      if(value == -1 || value != (*it).second) {
        return false;
      }
    }
    return true;
  }

  bool SimpleConstraintHandler::violate_constraints(const std::vector<param> &test_case) {
    for(auto constraint = constraints.cbegin(); constraint != constraints.cend(); ++constraint) {
      if(violate_constraint(test_case, *constraint)) {
        return true;
      }
    }
    return false;
  }

  inline bool SimpleConstraintHandler::violate_constraint(const std::vector<param>& test_case, const std::vector<std::pair<std::size_t, dval>>& constraint) {
    if(test_case.size() < constraint.size()) {
      return false;
    }

    std::size_t count = 0;
    for(auto it = constraint.cbegin(); it != constraint.cend(); ++it) {
      for(auto iit = test_case.cbegin(); iit != test_case.cend(); ++iit) {
        if((*iit).first == (*it).first && (*iit).second == (*it).second) {
          count++;
          break;
        }
      }
    }
    if(count == constraint.size()) {
      return true;
    }
    return false;
  }

  bool SimpleConstraintHandler::ground(dtest_case &test_case) {
    std::vector<std::size_t> indexes;

    // find unbound indexes
    std::size_t i = 0;
    for (auto it = test_case.begin(); it != test_case.end(); ++it, i++) {
      if ((*it) == -1) {
        indexes.push_back(i);
      }
    }
    if(indexes.size() == 0) {
      return true;
    }
    std::vector<dval> bound_values(indexes.size(), -1);
    i = 0;

LOOP:while(i < indexes.size()) {

       const dval max = params[indexes[i]];
       for(dval value = bound_values[i] + 1; value <= max; value++) {
         test_case[indexes[i]] = value;
         if(violate_constraints(test_case)) {
           continue;
         }
         bound_values[i] = value;
         i++;
         goto LOOP;
       }

       if(i == 0) {
         return false;
       }

       // unwind
       bound_values[i] = -1;
       test_case[indexes[i]] = -1;
       i--;
     }

     return true;
  }
}