% Version: 2.0-Simplified | Package: modules
% Version: 2.0-Simplified | Package: modules
classdef modules.modules
    % 演化博弈模块：在农户之间传播种植策略 (粮食 / 经济作物 / 混合)
    % 使用简单复制者动态，根据上一期各策略平均收益更新选择概率

    properties
        model           % 指向主模型
        strategies      % 可选策略列表
        probs           % 当前全局策略分布 (vector)
        learning_rate   % 调整速度
    end

    methods
        function obj = EvolutionaryGameModule(model)
            obj.model = model;
            obj.strategies = {'grain', 'cash', 'mixed'};  % 粮食、经济作物、混合
            obj.probs = [0.5 0.3 0.2];                    % 初始分布
            obj.learning_rate = 0.2;                      % 学习速率 / 复制者动态步长
        end

        function step(obj)
            % 每个时间步执行一次
            if isempty(obj.model.results.time_series)
                return;  % 尚无数据
            end

            % ----- 1. 计算各策略平均收益 -----
            households = obj.model.households;
            n = numel(households);
            payoff = zeros(1, numel(obj.strategies));
            count  = zeros(1, numel(obj.strategies));

            for i = 1:n
                h = households{i};
                % 简化：用种植决策作为策略标签
                if h.decision.plant_grain && ~h.decision.work_off_farm
                    idx = 1;     % 全粮食
                elseif ~h.decision.plant_grain && ~h.decision.work_off_farm
                    idx = 2;     % 全经济作物
                else
                    idx = 3;     % 混合/其他
                end
                payoff(idx) = payoff(idx) + h.income.total;
                count(idx)  = count(idx)  + 1;
            end
            avg_payoff = payoff ./ max(1, count);   % 避免除零

            % ----- 2. 复制者动态更新全局分布 -----
            total_payoff = sum(obj.probs .* avg_payoff);
            if total_payoff <= 0
                return;
            end
            new_probs = obj.probs + obj.learning_rate * (avg_payoff / total_payoff - obj.probs);
            new_probs = max(new_probs, 0);
            new_probs = new_probs / sum(new_probs);
            obj.probs = new_probs;

            % ----- 3. 根据分布重新抽样农户策略 -----
            cum = cumsum(obj.probs);
            for i = 1:n
                r = rand;
                if r < cum(1)
                    % 全粮食
                    households{i}.decision.plant_grain   = true;
                    households{i}.decision.work_off_farm = false;
                elseif r < cum(2)
                    % 全经济作物
                    households{i}.decision.plant_grain   = false;
                    households{i}.decision.work_off_farm = false;
                else
                    % 混合 => 根据原决策保留务工选项
                    households{i}.decision.plant_grain   = true;
                    % 混合情况下务工保持不变
                end
            end
        end
    end
end 
