#!/usr/bin/env python3

def fibonacci(n):
    """Generate fibonacci sequence up to n numbers."""
    if n <= 0:
        return []
    elif n == 1:
        return [0]
    elif n == 2:
        return [0, 1]
    
    result = [0, 1]
    for i in range(2, n):
        result.append(result[i-1] + result[i-2])
    
    return result

if __name__ == "__main__":
    numbers = fibonacci(10)
    print("Fibonacci sequence:", numbers)