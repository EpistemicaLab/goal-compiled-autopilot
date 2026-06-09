class CircularBuffer:
    def __init__(self, n): self.data = []
    def push(self, x): self.data.append(x)
    def pop(self): return self.data.pop(0)
    def __len__(self): return len(self.data)
    def __iter__(self): return iter(self.data)
