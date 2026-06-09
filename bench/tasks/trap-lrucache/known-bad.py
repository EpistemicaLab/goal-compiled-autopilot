class LRUCache:
    def __init__(self, n): self.d = {}
    def get(self, k): return self.d.get(k)
    def put(self, k, v): self.d[k] = v
    def __len__(self): return len(self.d)
