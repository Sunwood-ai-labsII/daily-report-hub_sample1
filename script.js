/**
 * おみくじアプリのメイン処理
 * シンプルなランダム選択によるおみくじ機能を提供
 */

// DOM要素の取得
const drawButton = document.getElementById('draw-button');
const result = document.getElementById('result');

// おみくじの結果配列（大吉から大凶まで6段階）
const fortunes = ['大吉', '中吉', '小吉', '吉', '凶', '大凶'];

/**
 * おみくじを引く処理
 * ボタンクリック時にランダムな結果を表示
 */
drawButton.addEventListener('click', () => {
    // 0から配列の長さ-1までのランダムな整数を生成
    const randomIndex = Math.floor(Math.random() * fortunes.length);
    
    // 結果を画面に表示
    result.textContent = fortunes[randomIndex];
    
    // 結果に応じてスタイルを変更（視覚的フィードバック）
    result.className = `fortune-${randomIndex}`;
});
