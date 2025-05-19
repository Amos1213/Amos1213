import time
import random
from collections import deque

class ClashRoyaleCommentator:
    def __init__(self):
        # 初始化遊戲狀態追蹤變數
        self.game_state = {
            'elixir': 0,
            'towers': {'player': [100, 100], 'opponent': [100, 100]},
            'troops_deployed': deque(maxlen=10),
            'spells_used': deque(maxlen=5),
            'time_elapsed': 0,
            'player_elixir_advantage': 0
        }
        
        # 評論資料庫
        self.comments_db = {
            'opening': [
                "比賽開始！雙方都在等待第一個行動。",
                "遊戲開始，看看誰會先出手！"
            ],
            'elixir_advantage': [
                "玩家現在有{advantage}點聖水優勢，是進攻的好時機！",
                "對手聖水領先{advantage}點，需要謹慎防守。"
            ],
            'tower_damage': [
                "玩家對皇家塔造成了嚴重傷害！",
                "對手的反擊對我們的塔造成了{damage}%傷害。"
            ],
            'troop_deploy': [
                "玩家部署了{card}來應對對手的攻勢。",
                "有趣的{card}選擇，看看效果如何。"
            ],
            'spell_use': [
                "精準的{spell}使用時機！",
                "{spell}在這個時候使用可能不是最佳選擇。"
            ],
            'clutch': [
                "比賽進入最後時刻，每一滴聖水都至關重要！",
                "加時賽！雙方都有機會獲勝！"
            ]
        }
    
    def update_game_state(self, event_type, data):
        """更新遊戲狀態"""
        if event_type == 'elixir_change':
            self.game_state['elixir'] = data['current']
            self.game_state['player_elixir_advantage'] = data['advantage']
        
        elif event_type == 'tower_damage':
            side = data['side']
            tower = data['tower']
            damage = data['damage']
            self.game_state['towers'][side][tower] -= damage
        
        elif event_type == 'card_played':
            if data['type'] == 'troop':
                self.game_state['troops_deployed'].append(data)
            else:
                self.game_state['spells_used'].append(data)
    
    def generate_comment(self):
        """根據當前遊戲狀態生成評論"""
        comments = []
        
        # 開場評論
        if self.game_state['time_elapsed'] < 5:
            comments.append(random.choice(self.comments_db['opening']))
        
        # 聖水優勢評論
        advantage = abs(self.game_state['player_elixir_advantage'])
        if advantage >= 3:
            template = random.choice(self.comments_db['elixir_advantage'])
            comments.append(template.format(advantage=advantage))
        
        # 皇家塔傷害評論
        for side in ['player', 'opponent']:
            for i, health in enumerate(self.game_state['towers'][side]):
                if health < 70 and health > 30:
                    comments.append(f"{side}的{i+1}號塔受到重創！")
                elif health <= 30:
                    comments.append(f"{side}的{i+1}號塔岌岌可危！")
        
        # 最近部署的卡牌評論
        if self.game_state['troops_deployed']:
            last_troop = self.game_state['troops_deployed'][-1]
            template = random.choice(self.comments_db['troop_deploy'])
            comments.append(template.format(card=last_troop['name']))
        
        # 最後30秒評論
        if self.game_state['time_elapsed'] > 150:  # 2分30秒後
            comments.append(random.choice(self.comments_db['clutch']))
        
        return comments
    
    def run(self):
        """主循環"""
        while True:
            # 這裡應該是從遊戲API獲取數據
            # 模擬數據更新
            self.game_state['time_elapsed'] += 1
            
            # 生成評論
            if random.random() < 0.3:  # 30%機率生成評論
                for comment in self.generate_comment():
                    print(f"[{self.game_state['time_elapsed']}秒] {comment}")
            
            time.sleep(1)  # 每秒更新一次


if __name__ == "__main__":
    commentator = ClashRoyaleCommentator()
    commentator.run()
