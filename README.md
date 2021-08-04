# 基於FPGA的打地鼠遊戲
### 透過FPGA板、keypad、點矩陣顯示器、七段顯示器實作的打地鼠遊戲
FPGA版使用DE0-CV，如下圖  
    
![image](https://images.offerup.com/29akojGOnCuHByERsvasaaHdhwg=/1008x756/a662/a6623b01792d4a3b9840056e364a7f0e.jpg)
## 遊戲畫面說明
  
![image](https://i.imgur.com/di60Fvx.jpg)  
- 遊戲時間為30秒，當前剩餘秒數顯示在七段顯示器的第34格。
- 點矩陣顯示器的右半邊是目前打地鼠的遊戲畫面，左半邊則可以忽略。
- 根據地鼠的位置按下keypad中對應的按鍵，則可以加一分，當前分數紀錄在七段顯示器的第56格。
- 一次只有一個地鼠，若0.5秒後還未打到，則會換一隻地鼠出現；若有即時打到則會立刻換一隻地鼠出現。
- 時間結束時，會有"GG"的字樣往左慢慢滑動離開
- 按下button0即可reset遊戲，重新遊玩
- 下圖為遊玩過程照片
  
![image](https://i.imgur.com/42AfJrk.jpg)  
![image](https://i.imgur.com/4ZKyrLf.jpg)  