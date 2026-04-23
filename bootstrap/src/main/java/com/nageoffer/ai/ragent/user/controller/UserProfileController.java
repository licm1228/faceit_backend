/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.nageoffer.ai.ragent.user.controller;

import com.nageoffer.ai.ragent.interview.entity.InterviewSessionEntity;
import com.nageoffer.ai.ragent.framework.context.UserContext;
import com.nageoffer.ai.ragent.framework.convention.Result;
import com.nageoffer.ai.ragent.framework.web.Results;
import com.nageoffer.ai.ragent.user.controller.vo.GrowthCurvePointVO;
import com.nageoffer.ai.ragent.user.controller.vo.InterviewHistoryDetailVO;
import com.nageoffer.ai.ragent.user.controller.vo.RecommendationVO;
import com.nageoffer.ai.ragent.user.controller.vo.UserProfileVO;
import com.nageoffer.ai.ragent.user.service.UserProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/user")
@RequiredArgsConstructor
public class UserProfileController {

    private final UserProfileService userProfileService;

    @GetMapping("/profile")
    public Result<UserProfileVO> getProfile() {
        String userId = UserContext.requireUser().getUserId();
        return Results.success(userProfileService.getProfile(userId));
    }

    @GetMapping("/interview-history")
    public Result<List<InterviewSessionEntity>> getInterviewHistory() {
        String userId = UserContext.requireUser().getUserId();
        return Results.success(userProfileService.getInterviewHistory(userId));
    }

    @GetMapping("/growth-curve")
    public Result<List<GrowthCurvePointVO>> getGrowthCurve(
            @RequestParam(value = "limit", required = false, defaultValue = "10") Integer limit) {
        String userId = UserContext.requireUser().getUserId();
        return Results.success(userProfileService.getGrowthCurve(userId, limit));
    }

    @GetMapping("/interview-history-detail")
    public Result<List<InterviewHistoryDetailVO>> getDetailedInterviewHistory() {
        String userId = UserContext.requireUser().getUserId();
        return Results.success(userProfileService.getDetailedInterviewHistory(userId));
    }

    @GetMapping("/recommendation")
    public Result<RecommendationVO> getRecommendation() {
        String userId = UserContext.requireUser().getUserId();
        return Results.success(userProfileService.getRecommendation(userId));
    }
}
