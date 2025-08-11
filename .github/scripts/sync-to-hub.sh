#!/bin/bash

# レポートハブに同期するスクリプト

set -e

# 必要な環境変数をチェック
: ${GITHUB_TOKEN:?}
: ${REPORT_HUB_REPO:?}
: ${TARGET_DIR:?}
: ${REPO_NAME:?}
: ${DATE:?}
: ${WEEK_NUMBER:?}

# daily-report-hubは既にクローン済み

# README.mdをコピー
cp README.md "$TARGET_DIR/" 2>/dev/null || echo "# $REPO_NAME" > "$TARGET_DIR/README.md"

# 当日のアクティビティファイルをコピー（全て.mdファイル）
cp daily_commits.md "$TARGET_DIR/"
cp daily_cumulative_diff.md "$TARGET_DIR/"
cp daily_diff_stats.md "$TARGET_DIR/"
cp daily_code_diff.md "$TARGET_DIR/"
cp latest_diff.md "$TARGET_DIR/"
cp latest_code_diff.md "$TARGET_DIR/"
cp daily_summary.md "$TARGET_DIR/"

# 詳細メタデータを作成
COMMIT_COUNT=$(wc -l < daily_commits_raw.txt)
FILES_CHANGED=$(grep -c '^' daily_cumulative_diff_raw.txt 2>/dev/null || echo "0")

cat > "$TARGET_DIR/metadata.json" << EOF
{
  "repository": "$GITHUB_REPOSITORY",
  "date": "$DATE",
  "week_folder": "$WEEK_FOLDER",
  "week_number": $WEEK_NUMBER,
  "week_start_date": "$WEEK_START_DATE",
  "week_end_date": "$WEEK_END_DATE",
  "branch": "$GITHUB_REF_NAME",
  "latest_commit_sha": "$GITHUB_SHA",
  "sync_timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "workflow_run": "$GITHUB_RUN_ID",
  "daily_commit_count": $COMMIT_COUNT,
  "daily_files_changed": $FILES_CHANGED,
  "has_activity": $([ $COMMIT_COUNT -gt 0 ] && echo "true" || echo "false"),
  "files": {
    "summary": "daily_summary.md",
    "commits": "daily_commits.md",
    "file_changes": "daily_cumulative_diff.md",
    "stats": "daily_diff_stats.md",
    "code_diff": "daily_code_diff.md",
    "latest_diff": "latest_diff.md",
    "latest_code_diff": "latest_code_diff.md"
  }
}
EOF

# タイムスタンプ付きでコミット・プッシュ
cd daily-report-hub
git add .

if git diff --staged --quiet; then
  echo "No changes to commit"
else
  git commit -m "📊 Weekly sync: $REPO_NAME ($DATE) - Week $WEEK_NUMBER - $COMMIT_COUNT commits"
  git push
  echo "✅ Successfully synced to report hub!"
fi