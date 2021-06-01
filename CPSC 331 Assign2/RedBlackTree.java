package ca.ucalgary.cpsc331;

class Node
{
	int key;
	int colour; 						// 0 for red, 1 for black

	Node parent;
	Node leftChild;
	Node rightChild;
	
}

public class RedBlackTree implements Dictionary{
	
	static final int RED = 0;
	static final int BLACK = 1;

	private Node Troot;
	private Node TNIL;
	
	/*
	 * Description: constructor 
	 */
	RedBlackTree()
	{
		TNIL = new Node();
		TNIL.colour = BLACK;
		TNIL.leftChild = null;
		TNIL.rightChild = null;
		Troot = TNIL;						// initialize empty tree
	}
	
	/*
	 * Description: page 288 used for printing binary search tree in sorted order
	 * 	- visit and print the root node
	 * 	- transverse the left sub tree (recursively call  inorder( root > left)
	 * 	- transverse the right sub tree (recursively call inorder (root > right)
	 */
	private void preOrderTreeWalk(Node startingNode)
	{
		if (startingNode != null)
		{
			//TODO add address and fix colour 
			System.out.printf("%s %d ", startingNode.key, startingNode.colour);	
			
			preOrderTreeWalk(startingNode.leftChild);
			preOrderTreeWalk(startingNode.rightChild);
		}
	}
	
	private Node iterativeTreeSearch(int value)
	{
		Node x = Troot;
		
		while (x != null && value != x.key)
		{
			if (value < x.key)
			{
				x = x.leftChild;
			}
			else
			{
				x = x.rightChild;
			}
		}
		
		return x;
	}
	
	private void rbInsertFixUp(Node insertedNode)
	{
		Node fixNode;
		
		while (insertedNode.parent.colour == RED)
		{		
			if (insertedNode.parent == insertedNode.parent.parent.leftChild)
			{
				fixNode = insertedNode.parent.parent.rightChild;
				
				if (fixNode.colour == RED)
				{
					insertedNode.parent.colour = BLACK;			
					fixNode.colour = BLACK;
					insertedNode.parent.parent.colour = RED;
					insertedNode = insertedNode.parent.parent;
				}
				else if (insertedNode == insertedNode.parent.rightChild)
				{
					insertedNode = insertedNode.parent;
					leftRotate(insertedNode);
					
					insertedNode.parent.colour = BLACK;
					insertedNode.parent.parent.colour = RED;
					rightRotate(insertedNode.parent.parent);
				}
			}
			else
			{
				fixNode = insertedNode.parent.parent.leftChild;
				
				if (fixNode.colour == RED)
				{
					insertedNode.parent.colour = BLACK;			
					fixNode.colour = BLACK;
					insertedNode.parent.parent.colour = RED;
					insertedNode = insertedNode.parent.parent;
				}
				else if (insertedNode == insertedNode.parent.leftChild)
				{
					insertedNode = insertedNode.parent;
					rightRotate(insertedNode);
					
					insertedNode.parent.colour = BLACK;
					insertedNode.parent.parent.colour = RED;
					leftRotate(insertedNode.parent.parent);
				}
			}
			
			if (insertedNode == Troot)
			{
				break;
			}
		}	
		Troot.colour = BLACK;
	}

	private void rbDeleteFixUp(Node x)
	{
		Node w;
		
		while (x != Troot &&  x.colour == BLACK)
		{
			if (x == x.parent.leftChild)
			{
				w = x.parent.rightChild;
				
				if (w.colour == RED)
				{
					w.colour = BLACK;
					x.parent.colour = RED;
					leftRotate(x.parent);
					w = x.parent.rightChild;
				}
				
				if (w.leftChild.colour == BLACK && w.rightChild.colour == BLACK)
				{
					w.colour = RED;
					x = x.parent;
				}
				else if (w.rightChild.colour == BLACK)
				{
					w.leftChild.colour = BLACK;
					w.colour = RED;
					rightRotate(w);
					w = x.parent.rightChild;
				}
				
				w.colour = x.parent.colour;
				x.parent.colour = BLACK;
				w.rightChild.colour = BLACK;
				leftRotate (x.parent);
				x = Troot;
			}
			else
			{
				w = x.parent.leftChild; 
				
				if (w.colour == RED)
				{
					w.colour = BLACK;
					x.parent.colour = RED;
					rightRotate(x.parent);
					w = x.parent.leftChild;
				}
				
				if (w.rightChild.colour == BLACK && w.leftChild.colour == BLACK)
				{
					w.colour = RED;
					x = x.parent;
				}
				else if (w.leftChild.colour == BLACK)
				{
					w.rightChild.colour = BLACK;
					w.colour = RED;
					leftRotate(w);
					w = x.parent.leftChild;
				}
				
				w.colour = x.parent.colour;
				x.parent.colour = BLACK;
				w.leftChild.colour = BLACK;
				rightRotate (x.parent);
				x = Troot;
			}
		}
		
		x.colour = BLACK;
	}

	private void rbTransplant(Node deleted, Node replace)
	{
		if (deleted.parent == null)
		{
			Troot = replace;
		}
		else if (deleted == deleted.parent.leftChild)
		{
			deleted.parent.leftChild = replace;
		}
		else
		{
			deleted.parent.rightChild = replace;
		}
		
		replace.parent = deleted.parent;
	}
		
	private Node treeMinimum(Node min)
	{
		while (min.leftChild != TNIL)
		{
			min = min.leftChild;
		}
		
		return min;
	}
	
	private void leftRotate(Node rotate)
	{
		Node holdRotate = rotate.rightChild;			// set holdRotate
		rotate.rightChild = holdRotate.leftChild;		// turn holdRotate's left subtree into rotate's right subtree
		
		if (holdRotate.leftChild != TNIL)
		{
			holdRotate.leftChild.parent = rotate;
		}
		
		holdRotate.parent = rotate.parent;				// links rotate's parents to holdRotate's
		
		if (rotate.parent == null)
		{
			this.Troot = holdRotate;
		}
		else if (rotate == rotate.parent.leftChild)
		{
			rotate.parent.leftChild = holdRotate;
		}
		else
		{
			rotate.parent.rightChild = holdRotate;
		}
		
		holdRotate.leftChild = rotate;					// put rotate on holdRotate's left
		rotate.parent = holdRotate;
	}
	
	private void rightRotate(Node rotate)
	{
		Node holdRotate = rotate.leftChild;			// set holdRotate
		rotate.leftChild = holdRotate.rightChild;		// turn holdRotate's left subtree into rotate's right subtree
		
		if (holdRotate.rightChild != TNIL)
		{
			holdRotate.rightChild.parent = rotate;
		}
		
		holdRotate.parent = rotate.parent;				// links rotate's parents to holdRotate's
		
		if (rotate.parent == null)
		{
			this.Troot = holdRotate;
		}
		else if (rotate == rotate.parent.rightChild)
		{
			rotate.parent.rightChild = holdRotate;
		}
		else
		{
			rotate.parent.leftChild = holdRotate;
		}
		
		holdRotate.rightChild = rotate;					// put rotate on holdRotate's left
		rotate.parent = holdRotate;
	}

	@Override
	public boolean empty() 
	{
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public void insert(int key) 
	{
		Node insertedNode = new Node();		// newNode = z
		insertedNode.key = key;
		insertedNode.parent = null;
		insertedNode.leftChild = TNIL;
		insertedNode.rightChild = TNIL;
		insertedNode.colour = RED;
		
		Node leaf = null;						// leaf = y
		Node rootNode = this.Troot;				// rootNode = x
		//if (rootNode == null)
		//{
		//	rootNode = insertedNode;
		//}
		
		while (rootNode != TNIL)
		{
			leaf = rootNode;
			 
			if (insertedNode.key < rootNode.key)
			{
				rootNode = rootNode.leftChild;
			}
			else
			{
				rootNode = rootNode.rightChild;
			}
		}
		
		insertedNode.parent = leaf;
		
		if (leaf == null)
		{
			Troot = insertedNode;
		}
		else if (insertedNode.key < leaf.key)
		{
			leaf.leftChild = insertedNode;
		}
		else
		{
			leaf.rightChild = insertedNode;
		}
		
				
		/* TODO 170-180 needs to be explained, directly copied from: https://www.programiz.com/dsa/red-black-tree*/
		if (insertedNode.parent == null)
		{
			insertedNode.colour = BLACK;
			return;
		}
		
		if (insertedNode.parent.parent == null)
		{
			return;
		}
		
		rbInsertFixUp(insertedNode);						// maintain property of red-black tree
	}

	@Override
	public void delete(int key) 
	{
		Node z = iterativeTreeSearch(key);
		
		Node y = z;
		Node x;
		
		int originalColour = y.colour;
		
		if (z.leftChild == TNIL)
		{
			x =z.rightChild;
			rbTransplant(z, z.rightChild);
		}
		else if (z.rightChild == TNIL)
		{
			x = z.leftChild;
			rbTransplant(z, z.leftChild);
		}
		else
		{
			y = treeMinimum(z.rightChild);
			originalColour = y.colour;
			x = y.rightChild;
			
			if (y.parent == z)
			{
				x.parent = y;
			}
			else
			{
				rbTransplant(y,y.rightChild);
				y.rightChild = z.rightChild;
				y.rightChild.parent = y;
			}
			rbTransplant(z, y);
			y.leftChild = z.leftChild;
			y.leftChild.parent = y;
			y.colour = z.colour;			
		}
		
		if (originalColour == BLACK)
		{
			rbDeleteFixUp(x);
		}
	}

	@Override
	public boolean member(int key) 
	{
		// TODO Auto-generated method stub
		return false;
	}
	
	@Override
	public String toString()
	{
		preOrderTreeWalk(this.Troot);
		
		return null;	
	}
	

}
