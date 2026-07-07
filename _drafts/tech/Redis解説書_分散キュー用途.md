# Redis解説書 - 分散キュー用途

## Redisとは
Redis（Remote Dictionary Server）は、インメモリデータ構造ストアです。データベース、キャッシュ、メッセージブローカーとして使用され、高速なデータアクセスが特徴です。

## 基本概念

### データ構造
Redisは様々なデータ型をサポートします：
- **String**: 単純な文字列値
- **List**: 順序付きの文字列リスト
- **Set**: 一意な文字列の集合
- **Hash**: フィールド-値ペアのマップ
- **Sorted Set**: スコア付きの順序集合

### 永続化
- **RDB**: 定期的なスナップショット
- **AOF**: 全ての書き込み操作をログ記録
- 両方の組み合わせも可能

## 分散キューでのRedis活用

### 1. 基本的なキュー操作

#### FIFO（先入先出）キュー
```bash
# データをキューの左端に追加
LPUSH work_queue "task1"
LPUSH work_queue "task2"
LPUSH work_queue "task3"

# キューの状態確認
LLEN work_queue  # 結果: 3
LRANGE work_queue 0 -1  # 結果: ["task3", "task2", "task1"]

# データをキューの右端から取得（ブロッキング）
BRPOP work_queue 0  # 結果: ["work_queue", "task1"]
BRPOP work_queue 0  # 結果: ["work_queue", "task2"]
```

#### LIFO（後入先出）スタック
```bash
# データをスタックに追加
LPUSH work_stack "task1"
LPUSH work_stack "task2"

# データをスタックから取得
LPOP work_stack  # 結果: "task2"
LPOP work_stack  # 結果: "task1"
```

### 2. 優先度付きキュー

#### Sorted Setを使用
```bash
# 優先度付きタスクを追加（スコアが小さいほど高優先度）
ZADD priority_queue 1 "urgent_task"
ZADD priority_queue 5 "normal_task"
ZADD priority_queue 10 "low_priority_task"

# 最高優先度のタスクを取得
ZPOPMIN priority_queue  # 結果: ["urgent_task", "1"]
```

### 3. 分散ロック

#### ファイルロック実装
```bash
# ロック取得（300秒後に自動解除）
SET lock:auth.py "worker-1" EX 300 NX

# ロック確認
GET lock:auth.py  # 結果: "worker-1"

# ロック解除
DEL lock:auth.py
```

#### より安全なロック（Luaスクリプト使用）
```lua
-- ロック取得スクリプト
if redis.call("get", KEYS[1]) == false then
    return redis.call("setex", KEYS[1], ARGV[1], ARGV[2])
else
    return nil
end
```

### 4. タスク状態管理

#### ハッシュを使った状態追跡
```bash
# タスク状態設定
HSET task:001 status "pending"
HSET task:001 worker ""
HSET task:001 created_at "2024-01-01T10:00:00Z"

# タスク状態更新
HSET task:001 status "in_progress"
HSET task:001 worker "worker-1"
HSET task:001 started_at "2024-01-01T10:05:00Z"

# タスク状態取得
HGETALL task:001
```

## 実践的なパターン

### 1. 信頼性のあるキュー

#### 処理中リストを使用
```python
import redis
import json
import time

class ReliableQueue:
    def __init__(self, redis_client):
        self.redis = redis_client
        self.queue_key = "tasks"
        self.processing_key = "processing"
        self.worker_id = "worker-1"
    
    def enqueue(self, task_data):
        """タスクをキューに追加"""
        task = {
            "id": f"task_{int(time.time())}",
            "data": task_data,
            "created_at": time.time()
        }
        self.redis.lpush(self.queue_key, json.dumps(task))
        return task["id"]
    
    def dequeue(self, timeout=0):
        """タスクを取得して処理中リストに移動"""
        # キューからタスクを取得
        result = self.redis.brpoplpush(
            self.queue_key, 
            self.processing_key, 
            timeout
        )
        
        if result:
            task = json.loads(result)
            # ワーカー情報を追加
            task["worker_id"] = self.worker_id
            task["started_at"] = time.time()
            
            # 処理中リストを更新
            self.redis.lrem(self.processing_key, 1, result)
            self.redis.lpush(self.processing_key, json.dumps(task))
            
            return task
        return None
    
    def complete_task(self, task_id):
        """タスク完了処理"""
        # 処理中リストから削除
        processing_tasks = self.redis.lrange(self.processing_key, 0, -1)
        for task_json in processing_tasks:
            task = json.loads(task_json)
            if task["id"] == task_id:
                self.redis.lrem(self.processing_key, 1, task_json)
                break
    
    def requeue_stale_tasks(self, timeout_seconds=300):
        """タイムアウトしたタスクを再キュー"""
        processing_tasks = self.redis.lrange(self.processing_key, 0, -1)
        current_time = time.time()
        
        for task_json in processing_tasks:
            task = json.loads(task_json)
            if current_time - task.get("started_at", 0) > timeout_seconds:
                # タスクを元のキューに戻す
                original_task = {
                    "id": task["id"],
                    "data": task["data"],
                    "created_at": task["created_at"]
                }
                self.redis.lpush(self.queue_key, json.dumps(original_task))
                self.redis.lrem(self.processing_key, 1, task_json)
```

### 2. パブリッシュ/サブスクライブ

#### リアルタイム通信
```python
import redis
import threading

class DistributedMessaging:
    def __init__(self, redis_client):
        self.redis = redis_client
        self.pubsub = redis_client.pubsub()
    
    def publish_event(self, channel, event_data):
        """イベントを発行"""
        self.redis.publish(channel, json.dumps(event_data))
    
    def subscribe_events(self, channels, callback):
        """イベントを購読"""
        self.pubsub.subscribe(*channels)
        
        def listen():
            for message in self.pubsub.listen():
                if message['type'] == 'message':
                    event_data = json.loads(message['data'])
                    callback(message['channel'], event_data)
        
        thread = threading.Thread(target=listen)
        thread.daemon = True
        thread.start()

# 使用例
messaging = DistributedMessaging(redis_client)

# イベント発行
messaging.publish_event("task_updates", {
    "task_id": "task_001",
    "status": "completed",
    "worker_id": "worker-1"
})

# イベント購読
def handle_event(channel, event_data):
    print(f"Channel: {channel}, Event: {event_data}")

messaging.subscribe_events(["task_updates", "worker_status"], handle_event)
```

### 3. レート制限

#### Sliding Window Counter
```python
class RateLimiter:
    def __init__(self, redis_client):
        self.redis = redis_client
    
    def is_allowed(self, key, limit, window_seconds):
        """レート制限チェック"""
        current_time = int(time.time())
        pipeline = self.redis.pipeline()
        
        # 古いエントリを削除
        pipeline.zremrangebyscore(
            key, 
            0, 
            current_time - window_seconds
        )
        
        # 現在のカウント取得
        pipeline.zcard(key)
        
        # 新しいエントリ追加
        pipeline.zadd(key, {str(current_time): current_time})
        
        # TTL設定
        pipeline.expire(key, window_seconds)
        
        results = pipeline.execute()
        current_count = results[1]
        
        return current_count < limit

# 使用例
limiter = RateLimiter(redis_client)

# ワーカーあたり1分間に最大10タスク
if limiter.is_allowed("worker:worker-1:tasks", 10, 60):
    # タスク実行
    process_task()
else:
    # レート制限に引っかかった
    time.sleep(1)
```

## Claude Code分散環境での活用例

### マスター制御システム
```python
class DistributedMaster:
    def __init__(self, redis_host):
        self.redis = redis.Redis(host=redis_host, decode_responses=True)
        self.task_queue = "claude_tasks"
        self.result_queue = "claude_results"
        self.worker_status = "worker_status"
        
    def distribute_large_task(self, project_description):
        """大きなタスクを小タスクに分解して配布"""
        # タスク分解（例：ファイル毎の作業）
        subtasks = self.analyze_and_split_task(project_description)
        
        task_ids = []
        for subtask in subtasks:
            structured_task = {
                "id": f"task_{int(time.time())}_{len(task_ids)}",
                "title": subtask["title"],
                "instruction": subtask["instruction"],
                "context": {
                    "files": subtask["files"],
                    "dependencies": subtask.get("dependencies", [])
                },
                "constraints": {
                    "max_execution_time": 1800,  # 30分
                    "locked_files": subtask.get("locked_files", [])
                }
            }
            
            # 依存関係チェック
            if self.check_dependencies(structured_task):
                self.redis.lpush(self.task_queue, json.dumps(structured_task))
                task_ids.append(structured_task["id"])
            else:
                # 依存関係待ちキューに追加
                self.redis.lpush("pending_tasks", json.dumps(structured_task))
        
        return task_ids
    
    def monitor_progress(self):
        """進捗監視"""
        while True:
            # 完了タスクチェック
            result = self.redis.brpop(self.result_queue, timeout=5)
            if result:
                self.process_completed_task(json.loads(result[1]))
            
            # ワーカーヘルスチェック
            self.check_worker_health()
            
            # 依存関係解決
            self.resolve_pending_tasks()
            
            time.sleep(1)
```

## パフォーマンス最適化

### 1. パイプライン使用
```python
# 悪い例：複数の個別コマンド
for i in range(1000):
    redis_client.lpush("queue", f"task_{i}")

# 良い例：パイプライン使用
pipeline = redis_client.pipeline()
for i in range(1000):
    pipeline.lpush("queue", f"task_{i}")
pipeline.execute()
```

### 2. 接続プール
```python
import redis

# 接続プール設定
pool = redis.ConnectionPool(
    host='redis-host',
    port=6379,
    max_connections=20,
    decode_responses=True
)

redis_client = redis.Redis(connection_pool=pool)
```

### 3. メモリ最適化
```bash
# メモリ使用量確認
MEMORY USAGE queue_name

# 期限切れキーの削除
CONFIG SET maxmemory-policy allkeys-lru
```

## セキュリティ考慮事項

### 1. 認証設定
```bash
# redis.conf
requirepass your_secure_password
```

### 2. ネットワーク制限
```bash
# 特定IPからのみアクセス許可
bind 127.0.0.1 10.0.0.0/8
```

### 3. コマンド制限
```bash
# 危険なコマンドを無効化
rename-command FLUSHDB ""
rename-command FLUSHALL ""
rename-command DEBUG ""
```

## 監視・運用

### メトリクス収集
```python
def collect_queue_metrics():
    metrics = {
        "queue_length": redis_client.llen("claude_tasks"),
        "processing_count": redis_client.llen("processing"),
        "completed_today": redis_client.zcard("completed:2024-01-01"),
        "active_workers": redis_client.scard("active_workers"),
        "memory_usage": redis_client.info("memory")["used_memory_human"]
    }
    return metrics
```

### アラート設定
```python
def check_alerts():
    queue_length = redis_client.llen("claude_tasks")
    if queue_length > 1000:
        send_alert("Queue backlog too high")
    
    processing_count = redis_client.llen("processing")
    if processing_count > 100:
        send_alert("Too many stuck tasks")
```

この解説書により、Redisを分散キューシステムとして効果的に活用し、Claude Code環境での協調作業を実現できます。