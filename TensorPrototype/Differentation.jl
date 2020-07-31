include("Operations.jl")

struct DifferentationOperation{rank} <: Operation{rank}
    shape::Tuple{}
    children::Tuple{AbstractTensor, ScalarVariable}
    function DifferentationOperation(A::AbstractTensor{0}, v::ScalarVariable)
        new{0}((), (A, v))
    end
end

function diff(A::AbstractTensor{0}, v::ScalarVariable)
    return DifferentationOperation(A, v)
end

function diff(s::Scalar, v::ScalarVariable)
    return DifferentationOperation(Tensor[s], v)
end

function differentiateNode(A::Tensor, y::ScalarVariable)
    if A.value[1] == y
        return DeltaTensor()
    else
        return ZeroTensor()
    end
end

function differentiateNode(Z::ZeroTensor, y::ScalarVariable)
    return Z
end

function differentiateNode(add::AddOperation, y::ScalarVariable)
    return +([differentiateNode(child, y) for child in add.children]...)
end

function differentiateNode(op::OuterProductOperation, y::ScalarVariable)
    (A, B) = op.children
    return A*diff(B, y) + diff(A, y)*B
end

function differentiateAST(diff::DifferentationOperation)
    return differentiateNode(diff.children...)
end

function differentiateAST(node::Node)
    return node
end